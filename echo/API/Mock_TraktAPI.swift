import Foundation

@Observable final class Mock_TraktAPI: TraktAPIProtocol {
    
    var isLoggedIn: Bool {
        true
    }
    
    var authorizationCode: String? {
        get { "mock_auth_code" }
        set {}
    }
    
    func authorize(completion: @escaping (Result<Bool, TraktAPIError>) -> Void) {
    }
    
    func deauthorize() {}
    
    func getPopularMovies() async throws -> [String] {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                continuation.resume(returning: ["Movie 1", "Movie 2", "Movie 3"])
            }
        }
    }
}
