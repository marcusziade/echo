import Foundation

enum TraktAPIError: Error {
    case tokenNotFound
    case refreshTokenNotFound
    case accessTokenNotSaved
    case encoding

    var errorDescription: String {
        switch self {
        case .tokenNotFound:
            return "Token not found"
        case .refreshTokenNotFound:
            return "Refresh token not found"
        case .accessTokenNotSaved:
            return "Error saving access token and refresh token to keychain:"
        case .encoding:
            return "Error encoding parameters:"
        }
    }
}
