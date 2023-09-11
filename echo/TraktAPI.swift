import Foundation
import KeychainAccess

final class TraktAPI {
    
    struct TokenResponse: Decodable {
        let accessToken: String
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
        }
    }
    
    struct Movie: Decodable {
        let title: String
    }
    
    var isLoggedIn: Bool {
        accessToken != nil
    }
    
    func authorize(authCode code: String) async throws -> Bool {
        guard
            URL(string: "https://trakt.tv/oauth/authorize?response_type=code&client_id=\(Keys.clientID)&redirect_uri=\(Keys.redirectURI)") != nil
        else {
            throw URLError(.badURL)
        }
        
        return try await getToken(authorizationCode: code)
    }
    
    private func getToken(authorizationCode: String) async throws -> Bool {
        guard let url = URL(string: "https://api.trakt.tv/oauth/token") else {
            throw URLError(.badURL)
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
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard
            let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200
        else {
            throw URLError(.badServerResponse)
        }
        
        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
        self.accessToken = tokenResponse.accessToken
        
        return true
    }
    
    func getPopularMovies() async throws -> [String] {
        guard
            let accessToken = self.accessToken,
            let url = URL(string: "https://api.trakt.tv/movies/popular")
        else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Keys.clientID, forHTTPHeaderField: "trakt-api-key")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard
            let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200
        else {
            throw URLError(.badServerResponse)
        }
        
        let movieList = try JSONDecoder().decode([Movie].self, from: data)
        return movieList.map { $0.title }
    }
    
    // MARK: - Private
    
    private let keychain = Keychain(service: "com.marcusziade.echo")
    private var accessToken: String? {
        get {
            keychain["accessToken"]
        } set {
            keychain["accessToken"] = newValue
        }
    }
}
