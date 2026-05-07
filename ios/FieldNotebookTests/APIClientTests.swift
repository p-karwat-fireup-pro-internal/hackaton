import XCTest
@testable import FieldNotebook

final class APIClientTests: XCTestCase {
    func testMaps423ToAccountLocked() async {
        MockURLProtocol.handler = { _ in
            let json = #"{"error":"account_locked","lockedUntil":1234567890000}"#.data(using: .utf8)!
            let res = HTTPURLResponse(url: URL(string: "https://test/")!, statusCode: 423,
                                      httpVersion: nil, headerFields: nil)!
            return (res, json)
        }
        let client = APIClient(baseURL: URL(string: "https://test")!, session: MockURLProtocol.session())
        do {
            let _: LoginResponse = try await client.send(.post, "/auth/login",
                                                         body: ["email": "x", "password": "y"],
                                                         as: LoginResponse.self)
            XCTFail("should throw")
        } catch APIError.accountLocked {
            // expected
        } catch {
            XCTFail("wrong error: \(error)")
        }
    }

    func testRefreshOn401IsAttemptedOnce() async {
        actor TokenStub: TokenSource {
            var accessToken: String? { "old" }
            var refreshCallCount = 0
            func handleUnauthorized() async -> String? {
                refreshCallCount += 1
                return "new"
            }
        }
        var firstCall = true
        MockURLProtocol.handler = { req in
            if firstCall {
                firstCall = false
                let res = HTTPURLResponse(url: req.url!, statusCode: 401, httpVersion: nil, headerFields: nil)!
                return (res, Data())
            } else {
                XCTAssertEqual(req.value(forHTTPHeaderField: "Authorization"), "Bearer new")
                let body = #"{"id":"u-1","email":"a@b.pl","displayName":"A","specialization":"e"}"#
                let res = HTTPURLResponse(url: req.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (res, body.data(using: .utf8)!)
            }
        }
        let stub = TokenStub()
        let client = APIClient(baseURL: URL(string: "https://test")!, session: MockURLProtocol.session())
        await client.setTokenSource(stub)
        let user: UserDTO = try! await client.send(.get, "/me", as: UserDTO.self)
        XCTAssertEqual(user.id, "u-1")
        let count = await stub.refreshCallCount
        XCTAssertEqual(count, 1)
    }
}
