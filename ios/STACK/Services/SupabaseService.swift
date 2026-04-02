import Foundation

class SupabaseService {
    static let shared = SupabaseService()
    private init() {}

    static let supabaseURL = "https://wfckqpnxnzzwbgbthtsb.supabase.co"
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndmY2txcG54bnp6d2JnYnRodHNiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM4NjU0MDUsImV4cCI6MjA4OTQ0MTQwNX0.dhp_UWWnKfkmAGvKrhyPbWnXDuq-ZSbfuBYULgt2ws4"

    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10.0
        config.timeoutIntervalForResource = 30.0
        return URLSession(configuration: config)
    }()

    // MARK: - Fetch (v2)

    func fetchRelayMessage(targetDay: Int) async -> RelayMessage? {
        guard let url = URL(string: "\(Self.supabaseURL)/rest/v1/relay_messages?target_day=eq.\(targetDay)&is_active=eq.true&order=created_at.desc&limit=10") else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        applyHeaders(to: &request)
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                #if DEBUG
                let code = (response as? HTTPURLResponse)?.statusCode ?? -1
                print("[RELAY FETCH] HTTP error: \(code)")
                #endif
                return nil
            }

            #if DEBUG
            if let raw = String(data: data.prefix(500), encoding: .utf8) {
                print("[RELAY FETCH] Raw response (\(data.count) bytes): \(raw)")
            }
            #endif

            let decoder = makeDecoder()
            let messages = try decoder.decode([RelayMessage].self, from: data)
            #if DEBUG
            print("[RELAY FETCH] Decoded \(messages.count) messages for day \(targetDay)")
            #endif
            return messages.randomElement()
        } catch {
            #if DEBUG
            print("[RELAY FETCH] Error for day \(targetDay): \(error)")
            #endif
            return nil
        }
    }

    // MARK: - Fetch (v1 deprecated wrapper)

    func fetchRelayMessage(milestone: Int) async -> RelayMessage? {
        await fetchRelayMessage(targetDay: milestone)
    }

    // MARK: - Submit (v2 — rate-limited via RPC)

    enum RelaySubmitError: LocalizedError {
        case notAuthenticated
        case duplicateTargetDay
        case rateLimitExceeded
        case invalidTextLength
        case serverError(String)

        var errorDescription: String? {
            switch self {
            case .notAuthenticated: return "Sign in to leave a relay message."
            case .duplicateTargetDay: return "You've already left a message for this milestone."
            case .rateLimitExceeded: return "You can submit up to 5 messages per day."
            case .invalidTextLength: return "Message must be between 10 and 500 characters."
            case .serverError(let msg): return msg
            }
        }
    }

    func submitRelayMessage(text: String, targetDay: Int, writerDay: Int) async throws {
        guard let url = URL(string: "\(Self.supabaseURL)/rest/v1/rpc/submit_relay_message") else {
            throw URLError(.badURL)
        }

        guard let authToken = AuthService.shared.accessToken else {
            throw RelaySubmitError.notAuthenticated
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        applyAuthHeaders(to: &request, token: authToken)

        let body: [String: Any] = [
            "p_text": text,
            "p_target_day": targetDay,
            "p_writer_day": writerDay
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let ok = json["ok"] as? Bool, !ok,
           let error = json["error"] as? String {
            switch error {
            case "AUTHENTICATION_REQUIRED": throw RelaySubmitError.notAuthenticated
            case "DUPLICATE_TARGET_DAY": throw RelaySubmitError.duplicateTargetDay
            case "RATE_LIMIT_EXCEEDED": throw RelaySubmitError.rateLimitExceeded
            case "INVALID_TEXT_LENGTH": throw RelaySubmitError.invalidTextLength
            default: throw RelaySubmitError.serverError(error)
            }
        }
    }

    // MARK: - Submit (v1 deprecated wrapper)

    func submitRelayMessage(text: String, milestone: Int) async throws {
        try await submitRelayMessage(text: text, targetDay: milestone, writerDay: milestone)
    }

    // MARK: - Report

    func reportRelayMessage(id: String) async throws {
        guard let url = URL(string: "\(Self.supabaseURL)/rest/v1/rpc/report_relay_message") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        applyHeaders(to: &request)

        let body: [String: Any] = ["message_id": id]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }

    // MARK: - User Data Sync

    struct UserDataResponse: Decodable {
        let chapters: [Chapter]?
        let received_relay_days: [Int]?
        let written_relay_days: [Int]?
    }

    func syncUserData(chapters: [Chapter], relayDays: [Int], writtenDays: [Int], authToken: String) async {
        guard let url = URL(string: "\(Self.supabaseURL)/rest/v1/user_data?on_conflict=user_id") else { return }
        guard let userId = AuthService.shared.userId else { return }

        let chaptersData: [[String: Any]] = chapters.map { chapter in
            var dict: [String: Any] = [
                "id": chapter.id,
                "startDate": ISO8601DateFormatter().string(from: chapter.startDate),
                "chapterNumber": chapter.chapterNumber
            ]
            if let endDate = chapter.endDate {
                dict["endDate"] = ISO8601DateFormatter().string(from: endDate)
            }
            return dict
        }

        let body: [String: Any] = [
            "user_id": userId,
            "chapters": chaptersData,
            "received_relay_days": relayDays,
            "written_relay_days": writtenDays
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        applyAuthHeaders(to: &request, token: authToken)
        request.setValue("return=minimal,resolution=merge-duplicates", forHTTPHeaderField: "Prefer")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        _ = try? await session.data(for: request)
    }

    func fetchUserData(authToken: String) async -> UserDataResponse? {
        guard let userId = AuthService.shared.userId else { return nil }
        guard let url = URL(string: "\(Self.supabaseURL)/rest/v1/user_data?user_id=eq.\(userId)&limit=1") else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        applyAuthHeaders(to: &request, token: authToken)
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else { return nil }

            let decoder = makeDecoder()
            let results = try decoder.decode([UserDataResponse].self, from: data)
            return results.first
        } catch {
            return nil
        }
    }

    func deleteUserData(authToken: String) async {
        guard let userId = AuthService.shared.userId else { return }
        guard let url = URL(string: "\(Self.supabaseURL)/rest/v1/user_data?user_id=eq.\(userId)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        applyAuthHeaders(to: &request, token: authToken)

        _ = try? await session.data(for: request)
    }

    // MARK: - Helpers

    private func applyHeaders(to request: inout URLRequest) {
        request.setValue(Self.supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(Self.supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }

    private func applyAuthHeaders(to request: inout URLRequest, token: String) {
        request.setValue(Self.supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }

    private func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        // Supabase returns ISO 8601 timestamps with fractional seconds
        // (e.g. "2026-03-21T16:31:14.908308+00:00"). The built-in .iso8601
        // strategy does not reliably parse fractional seconds on all iOS
        // versions, which causes the entire decode to throw — even for
        // optional Date? fields — because the key IS present in the JSON.
        let isoWithFrac = ISO8601DateFormatter()
        isoWithFrac.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let isoPlain = ISO8601DateFormatter()
        isoPlain.formatOptions = [.withInternetDateTime]
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            if let date = isoWithFrac.date(from: string) { return date }
            if let date = isoPlain.date(from: string) { return date }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot parse date: \(string)"
            )
        }
        return decoder
    }
}
