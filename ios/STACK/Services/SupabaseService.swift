import Foundation

class SupabaseService {
    static let shared = SupabaseService()
    private init() {}

    static let supabaseURL = "https://wfckqpnxnzzwbgbthtsb.supabase.co"
    static let supabaseAnonKey = "REPLACE_WITH_SUPABASE_ANON_KEY" // TODO: replace from Supabase dashboard → Settings → API → anon/public key

    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 2.0
        config.timeoutIntervalForResource = 4.0
        return URLSession(configuration: config)
    }()

    // MARK: - Fetch

    /// Fetch a relay message for a given milestone. Returns nil on error, timeout, or empty pool.
    func fetchRelayMessage(milestone: Int) async -> RelayMessage? {
        guard let url = URL(string: "\(Self.supabaseURL)/rest/v1/relay_messages?milestone_days=eq.\(milestone)&is_active=eq.true&order=created_at.desc&limit=10") else {
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

    // MARK: - Submit

    /// Submit a new relay message. Throws on non-2xx response.
    func submitRelayMessage(text: String, milestone: Int) async throws {
        guard let url = URL(string: "\(Self.supabaseURL)/rest/v1/relay_messages") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        applyHeaders(to: &request)
        request.setValue("return=minimal", forHTTPHeaderField: "Prefer")

        let body: [String: Any] = [
            "milestone_days": milestone,
            "text": text
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }

    // MARK: - Report

    /// Report a relay message as inappropriate. Throws on non-2xx response.
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
