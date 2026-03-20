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
        guard Self.supabaseAnonKey != "REPLACE_WITH_SUPABASE_ANON_KEY" else { return nil }
        guard let url = URL(string: "\(Self.supabaseURL)/rest/v1/relay_messages?target_day=eq.\(targetDay)&is_active=eq.true&order=created_at.desc&limit=10") else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        applyHeaders(to: &request)

        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                return nil
            }

            let decoder = makeDecoder()
            let messages = try decoder.decode([RelayMessage].self, from: data)
            return messages.randomElement()
        } catch {
            return nil
        }
    }

    // MARK: - Fetch (v1 deprecated wrapper)

    func fetchRelayMessage(milestone: Int) async -> RelayMessage? {
        await fetchRelayMessage(targetDay: milestone)
    }

    // MARK: - Submit (v2)

    func submitRelayMessage(text: String, targetDay: Int, writerDay: Int) async throws {
        guard Self.supabaseAnonKey != "REPLACE_WITH_SUPABASE_ANON_KEY" else {
            throw URLError(.userAuthenticationRequired)
        }
        guard let url = URL(string: "\(Self.supabaseURL)/rest/v1/relay_messages") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        applyHeaders(to: &request)
        request.setValue("return=minimal", forHTTPHeaderField: "Prefer")

        let body: [String: Any] = [
            "target_day": targetDay,
            "writer_day": writerDay,
            "text": text,
            "is_seed": false
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
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
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
