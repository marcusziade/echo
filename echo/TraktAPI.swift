import Foundation
import KeychainAccess
import Observation

@Observable final class TraktAPI {
    
    var isLoggedIn: Bool {
        accessToken != nil
    }
    
    func authorize(authCode code: String) async throws -> Bool {
        guard URL(string: "\(baseURL)/oauth/authorize?response_type=code&client_id=\(Keys.clientID)&redirect_uri=\(Keys.redirectURI)") != nil else {
            throw TraktAPIError.badURL
        }
        return try await getToken(authorizationCode: code)
    }
    
    func deauthorize() {
        accessToken = nil
    }
    
    private func getToken(authorizationCode: String) async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/oauth/token") else {
            throw TraktAPIError.badURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let parameters = [
            "code": authorizationCode,
            "client_id": Keys.clientID,
            "client_secret": Keys.clientSecret,
            "redirect_uri": Keys.redirectURI,
            "grant_type": "authorization_code",
        ]
        
        do {
            request.httpBody = try JSONEncoder().encode(parameters)
        } catch {
            throw TraktAPIError.encoding
        }
        
        request.setJSONContentType()
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard
            let httpResponse = response as? HTTPURLResponse,
            httpResponse.isSuccessful
        else {
            throw TraktAPIError.badResponse
        }
        
        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
        accessToken = tokenResponse.accessToken
        return true
    }
    
    func getPopularMovies() async throws -> [String] {
        guard
            let accessToken,
            let url = URL(string: "\(baseURL)/movies/popular")
        else {
            throw TraktAPIError.badURL
        }
        
        var request = URLRequest(url: url)
        request.addAuthorizationHeader(bearerToken: accessToken)
        request.setJSONContentType()
        request.addValue(Keys.clientID, forHTTPHeaderField: "trakt-api-key")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard
            let httpResponse = response as? HTTPURLResponse,
            httpResponse.isSuccessful
        else {
            throw TraktAPIError.badResponse
        }
        
        let movieList = try JSONDecoder().decode([Movie].self, from: data)
        return movieList.map { $0.title }
    }
    
    // MARK: - Private
    
    private let baseURL = "https://api.trakt.tv"
    private let keychain = Keychain(service: "com.marcusziade.echo")
    
    private var accessToken: String? {
        get { keychain["accessToken"] }
        set { keychain["accessToken"] = newValue }
    }
}

// MARK: - Extensions

private extension URLRequest {
    mutating func setJSONContentType() {
        addValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    
    mutating func addAuthorizationHeader(bearerToken: String) {
        addValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
    }
}

private extension HTTPURLResponse {
    var isSuccessful: Bool {
        return (200...299).contains(statusCode)
    }
}
