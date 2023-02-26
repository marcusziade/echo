import Foundation
import KeychainAccess
import OAuthSwift

final class TraktManager {
    
    var isAuthenticated: Bool {
        keychain[string: "TraktAPIToken"] != nil
    }
    
    init(
        clientId: String, clientSecret: String, callbackURL: String
    ) {
        oauthswift = OAuth2Swift(
            consumerKey: clientId,
            consumerSecret: clientSecret,
            authorizeUrl: "https://trakt.tv/oauth/authorize",
            accessTokenUrl: "https://api.trakt.tv/oauth/token",
            responseType: "code"
        )
        keychain = Keychain(service: "com.marcusziade.echo.TraktAPIManager")
    }
    
    func authorize() async throws {
        try await withCheckedThrowingContinuation { continuation in
            oauthswift.authorize(
                withCallbackURL: callbackURL,
                scope: "public",
                state: "RANDOM_STATE"
            ) { [unowned self] result in
                switch result {
                case .success(let (credential, _, _)):
                    saveAccessToken(credential.oauthToken, refreshToken: credential.oauthRefreshToken)
                    continuation.resume(returning: Void())
                case .failure(let error):
                    print(error, error.localizedDescription, error.errorCode)
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func refreshAccessToken() async throws {
        guard let refreshToken = keychain[string: "TraktAPIRefreshToken"] else {
            throw TraktManagerError.refreshTokenNotFound
        }
        
        try await withCheckedThrowingContinuation { continuation in
            oauthswift.renewAccessToken(withRefreshToken: refreshToken) { [unowned self] result in
                switch result {
                case .success(let (credential, _, _)):
                    saveAccessToken(credential.oauthToken, refreshToken: credential.oauthRefreshToken)
                    continuation.resume(returning: ())
                case .failure(let error):
                    print(error, error.localizedDescription, error.errorCode)
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func request(
        _ url: String,
        method: OAuthSwiftHTTPRequest.Method,
        parameters: [String: Any]
    ) async throws -> Data {
        guard let token = keychain[string: "TraktAPIToken"] else {
            throw TraktManagerError.tokenNotFound
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let headers: [String: String] = [
                "trakt-api-version": "2",
                "trakt-api-key": oauthswift.client.credential.consumerKey,
                "Authorization": "Bearer \(token)",
            ]
            
            oauthswift.client.request(url, method: method, parameters: parameters, headers: headers) { result in
                switch result {
                case .success(let oAuthResponse):
                    continuation.resume(returning: oAuthResponse.data)
                case .failure(let error):
                    print(error, error.localizedDescription, error.errorCode)
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private let callbackURL: String = "urn:ietf:wg:oauth:2.0:oob"
    private let oauthswift: OAuth2Swift
    private let keychain: Keychain
    
    private func saveAccessToken(_ accessToken: String, refreshToken: String) {
        do {
            try keychain.set(accessToken, key: "TraktAPIToken")
            try keychain.set(refreshToken, key: "TraktAPIRefreshToken")
        } catch let error {
            print(TraktManagerError.accessTokenNotSaved.errorDescription, error.localizedDescription)
        }
    }
}
