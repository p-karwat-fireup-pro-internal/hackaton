import Foundation

protocol TokenSource: AnyObject {
    var accessToken: String? { get async }
    func handleUnauthorized() async -> String?  // returns new access token, or nil if refresh failed
}

actor APIClient {
    let baseURL: URL
    let session: URLSession
    weak var tokenSource: TokenSource?

    init(baseURL: URL = AppConfig.apiBaseURL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    private func makeRequest(
        _ method: String,
        _ path: String,
        body: Data? = nil,
        contentType: String? = "application/json",
        accessToken: String?
    ) -> URLRequest {
        var url = baseURL
        url.append(path: path)
        var req = URLRequest(url: url)
        req.httpMethod = method
        if let body { req.httpBody = body }
        if let contentType { req.setValue(contentType, forHTTPHeaderField: "Content-Type") }
        if let accessToken { req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization") }
        return req
    }

    func send<T: Decodable>(
        _ method: String,
        _ path: String,
        body: (any Encodable)? = nil,
        as: T.Type
    ) async throws -> T {
        let data = try await sendRaw(method, path, body: body, expectingJSON: true)
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decoding
        }
    }

    func sendVoid(_ method: String, _ path: String, body: (any Encodable)? = nil) async throws {
        _ = try await sendRaw(method, path, body: body, expectingJSON: false)
    }

    func sendMultipart<T: Decodable>(
        _ path: String,
        fields: [String: String],
        fileField: String,
        fileData: Data,
        filename: String,
        mimeType: String,
        as: T.Type
    ) async throws -> T {
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        for (k, v) in fields {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(k)\"\r\n\r\n".data(using: .utf8)!)
            body.append(v.data(using: .utf8)!)
            body.append("\r\n".data(using: .utf8)!)
        }
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fileField)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        let token = await tokenSource?.accessToken
        var req = makeRequest("POST", path, body: body,
                              contentType: "multipart/form-data; boundary=\(boundary)",
                              accessToken: token)
        return try await execute(&req, asJSON: T.self)
    }

    private func sendRaw(
        _ method: String,
        _ path: String,
        body: (any Encodable)?,
        expectingJSON: Bool
    ) async throws -> Data {
        let token = await tokenSource?.accessToken
        let payload: Data?
        if let body { payload = try JSONEncoder().encode(AnyEncodable(body)) } else { payload = nil }
        var req = makeRequest(method, path, body: payload, accessToken: token)
        let (data, response) = try await runWithRefreshOn401(&req)
        guard let http = response as? HTTPURLResponse else { throw APIError.network }
        try mapStatus(http, data: data)
        return data
    }

    private func execute<T: Decodable>(_ req: inout URLRequest, asJSON: T.Type) async throws -> T {
        let (data, response) = try await runWithRefreshOn401(&req)
        guard let http = response as? HTTPURLResponse else { throw APIError.network }
        try mapStatus(http, data: data)
        do { return try JSONDecoder().decode(T.self, from: data) }
        catch { throw APIError.decoding }
    }

    private func runWithRefreshOn401(_ req: inout URLRequest) async throws -> (Data, URLResponse) {
        let (data, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, http.statusCode == 401 else { return (data, response) }
        guard let newToken = await tokenSource?.handleUnauthorized() else { throw APIError.unauthorized }
        req.setValue("Bearer \(newToken)", forHTTPHeaderField: "Authorization")
        return try await session.data(for: req)
    }

    private func mapStatus(_ http: HTTPURLResponse, data: Data) throws {
        switch http.statusCode {
        case 200..<300: return
        case 400:       throw APIError.invalidRequest
        case 401:       throw APIError.unauthorized
        case 403:       throw APIError.forbidden
        case 404:       throw APIError.notFound
        case 409:
            let payload = try? JSONDecoder().decode(ConflictBody.self, from: data)
            throw APIError.conflict(currentStatus: payload?.current)
        case 415:       throw APIError.invalidRequest
        case 423:
            let payload = try? JSONDecoder().decode(LockedBody.self, from: data)
            let until = payload.flatMap { Date(timeIntervalSince1970: TimeInterval($0.lockedUntil) / 1000) }
                ?? Date().addingTimeInterval(15 * 60)
            throw APIError.accountLocked(lockedUntil: until)
        case 429:
            let retryAfter = http.value(forHTTPHeaderField: "Retry-After").flatMap(Int.init)
            throw APIError.rateLimited(retryAfterSec: retryAfter)
        case 500..<600: throw APIError.server
        default:        throw APIError.network
        }
    }
}

extension APIClient {
    func setTokenSource(_ source: TokenSource) {
        self.tokenSource = source
    }
}

private struct ConflictBody: Decodable { let current: String? }
private struct LockedBody: Decodable { let lockedUntil: Int }

// AnyEncodable wrapper so the Encodable existential can be encoded.
private struct AnyEncodable: Encodable {
    let value: any Encodable
    init(_ value: any Encodable) { self.value = value }
    func encode(to encoder: Encoder) throws { try value.encode(to: encoder) }
}
