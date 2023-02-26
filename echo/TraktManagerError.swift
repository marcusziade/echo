import Foundation

enum TraktManagerError: Error {
    case tokenNotFound
    case refreshTokenNotFound
    case accessTokenNotSaved
    
    var errorDescription: String {
        switch self {
        case .tokenNotFound:
            return "Token not found"
        case .refreshTokenNotFound:
            return "Refresh token not found"
        case .accessTokenNotSaved:
            return "Error saving access token and refresh token to keychain:"
        }
    }
}
