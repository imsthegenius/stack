import Foundation

class SupabaseService {
    static let shared = SupabaseService()
    private init() {}

    static let supabaseURL = "https://wfckqpnxnzzwbgbthtsb.supabase.co"
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndmY2txcG54bnp6d2JnYnRodHNiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM4NjU0MDUsImV4cCI6MjA4OTQ0MTQwNX0.dhp_UWWnKfkmAGvKrhyPbWnXDuq-ZSbfuBYULgt2ws4"

    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 2.0
        config.timeoutIntervalForResource = 4.0
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

    // MARK: - Helpers

    private func applyHeaders(to request: inout URLRequest) {
        request.setValue(Self.supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(Self.supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }

    private func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
