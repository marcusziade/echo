import Foundation
import Combine
import Observation

@Observable final class AuthenticationManager {
    var animationAmount: CGFloat = 1
    var showSignIn: Bool = false
    var authCode: String?
    var isError: Bool = false
    var errorMessage: String?
    var isLoggedIn: Bool = false
    
    func authorize() async {
        do {
            let success = try await api.authorize(authCode: authCode ?? "")
            isError = !success
            isLoggedIn = api.isLoggedIn
        } catch {
            isError = true
            errorMessage = error.localizedDescription
        }
    }

    // MARK: Private
    
    private let api = TraktAPI()
}
