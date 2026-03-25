import Foundation
import AuthenticationServices
import CryptoKit

@Observable
class AuthService {
    static let shared = AuthService()

    var isSignedIn: Bool = false
    var userId: String?
    var accessToken: String?
    var refreshToken: String?
    var userEmail: String?
    var hasSkippedSignIn: Bool = false
    var isLoading: Bool = false
    var errorMessage: String?

    private let defaults = UserDefaults(suiteName: "group.com.twohundred.stack") ?? .standard

    private static let accessTokenKey = "com.twohundred.stack.access_token"
    private static let refreshTokenKey = "com.twohundred.stack.refresh_token"
    private static let userIdKey = "com.twohundred.stack.user_id"
    private static let emailKey = "com.twohundred.stack.email"
    private static let appleAuthCodeKey = "com.twohundred.stack.apple_auth_code"

    private init() {
        loadFromKeychain()
        hasSkippedSignIn = defaults.bool(forKey: "has_skipped_sign_in")

        if accessToken != nil {
            Task { await refreshSession() }
        }
    }

    // MARK: - Sign In with Apple

    func signInWithApple(idToken: String, nonce: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        guard let url = URL(string: "\(SupabaseService.supabaseURL)/auth/v1/token?grant_type=id_token") else {
            errorMessage = "Invalid configuration"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(SupabaseService.supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "provider": "apple",
            "id_token": idToken,
            "nonce": nonce
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
            errorMessage = "Failed to create request"
            return
        }
        request.httpBody = httpBody

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                errorMessage = "Sign in failed. Please try again."
                return
            }

            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                errorMessage = "Unexpected response"
                return
            }

            let access = json["access_token"] as? String
            let refresh = json["refresh_token"] as? String

            // Extract user info
            var uid: String?
            var email: String?
            if let user = json["user"] as? [String: Any] {
                uid = user["id"] as? String
                email = user["email"] as? String
            }

            guard let accessToken = access, let refreshToken = refresh, let userId = uid else {
                errorMessage = "Invalid session"
                return
            }

            saveSession(accessToken: accessToken, refreshToken: refreshToken, userId: userId, email: email)
        } catch {
            errorMessage = "Connection error. Please try again."
        }
    }

    // MARK: - Refresh Session

    func refreshSession() async {
        guard let currentRefresh = refreshToken else {
            signOutLocally()
            return
        }

        guard let url = URL(string: "\(SupabaseService.supabaseURL)/auth/v1/token?grant_type=refresh_token") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(SupabaseService.supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["refresh_token": currentRefresh]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let newAccess = json["access_token"] as? String,
                  let newRefresh = json["refresh_token"] as? String else {
                signOutLocally()
                return
            }

            var uid = userId
            var email = userEmail
            if let user = json["user"] as? [String: Any] {
                uid = user["id"] as? String ?? uid
                email = user["email"] as? String ?? email
            }

            saveSession(accessToken: newAccess, refreshToken: newRefresh, userId: uid ?? "", email: email)
        } catch {
            // Network error — keep existing session, don't sign out
        }
    }

    // MARK: - Sign Out

    func signOut() {
        signOutLocally()
    }

    // MARK: - Apple Auth Code (for token revocation)

    func storeAppleAuthCode(_ code: String) {
        KeychainHelper.save(key: Self.appleAuthCodeKey, string: code)
    }

    // MARK: - Delete Account

    func deleteAccount() async -> Bool {
        guard let token = accessToken else { return false }

        guard let url = URL(string: "\(SupabaseService.supabaseURL)/functions/v1/delete-user") else { return false }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(SupabaseService.supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Send Apple auth code for token revocation
        let appleAuthCode = KeychainHelper.loadString(key: Self.appleAuthCodeKey)
        if let code = appleAuthCode {
            let body = ["apple_auth_code": code]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                return false
            }

            clearAllData()
            return true
        } catch {
            return false
        }
    }

    // MARK: - Skip Sign In

    func skipSignIn() {
        hasSkippedSignIn = true
        defaults.set(true, forKey: "has_skipped_sign_in")
    }

    func clearSkipAndShowSignIn() {
        hasSkippedSignIn = false
        defaults.set(false, forKey: "has_skipped_sign_in")
    }

    // MARK: - Nonce Helpers

    static func randomNonceString(length: Int = 32) -> String {
        guard length > 0 else { return "" }
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        guard errorCode == errSecSuccess else { return UUID().uuidString }
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }

    static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }

    // MARK: - Private

    private func saveSession(accessToken: String, refreshToken: String, userId: String, email: String?) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.userId = userId
        self.userEmail = email
        self.isSignedIn = true
        self.hasSkippedSignIn = false

        KeychainHelper.save(key: Self.accessTokenKey, string: accessToken)
        KeychainHelper.save(key: Self.refreshTokenKey, string: refreshToken)
        KeychainHelper.save(key: Self.userIdKey, string: userId)
        if let email = email {
            KeychainHelper.save(key: Self.emailKey, string: email)
        }
        defaults.set(false, forKey: "has_skipped_sign_in")
    }

    private func loadFromKeychain() {
        accessToken = KeychainHelper.loadString(key: Self.accessTokenKey)
        refreshToken = KeychainHelper.loadString(key: Self.refreshTokenKey)
        userId = KeychainHelper.loadString(key: Self.userIdKey)
        userEmail = KeychainHelper.loadString(key: Self.emailKey)
        isSignedIn = accessToken != nil
    }

    private func signOutLocally() {
        accessToken = nil
        refreshToken = nil
        userId = nil
        userEmail = nil
        isSignedIn = false

        KeychainHelper.delete(key: Self.accessTokenKey)
        KeychainHelper.delete(key: Self.refreshTokenKey)
        KeychainHelper.delete(key: Self.userIdKey)
        KeychainHelper.delete(key: Self.emailKey)
        KeychainHelper.delete(key: Self.appleAuthCodeKey)
    }

    private func clearAllData() {
        signOutLocally()

        let defaults = UserDefaults(suiteName: "group.com.twohundred.stack") ?? .standard
        let allKeys = ["chapters_data", "today_pledge_date", "has_completed_onboarding",
                       "lifetime_purchased", "received_relay_days", "written_relay_days",
                       "blocked_relay_message_ids", "has_skipped_sign_in",
                       "widget_current_days", "widget_chapter_number", "widget_total_days",
                       "widget_is_milestone_today", "widget_pledged_today", "widget_milestone_label"]
        for key in allKeys {
            defaults.removeObject(forKey: key)
        }

        // Clear iCloud KVS
        let cloud = NSUbiquitousKeyValueStore.default
        for key in ["chapters_data", "has_completed_onboarding", "received_relay_days"] {
            cloud.removeObject(forKey: key)
        }
        cloud.synchronize()

        hasSkippedSignIn = false
    }
}
