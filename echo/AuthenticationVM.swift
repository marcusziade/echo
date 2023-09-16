import Foundation
import Combine
import Observation

@Observable final class AuthenticationVM {
    var animationAmount: CGFloat = 1
    var showSignIn: Bool = false
    var authCode: String?
    var isError: Bool = false
    var errorMessage: String?
    var isLoggedIn = false
    
    init() {
        isLoggedIn = api.isLoggedIn
    }
    
    func authorize() async {
        do {
            let success = try await api.authorize(authCode: authCode ?? "")
            isError = !success
            isLoggedIn = success
        } catch {
            isError = true
            errorMessage = error.localizedDescription
        }
    }
    
    func deauthorize() {
        api.deauthorize()
        isLoggedIn = false
    }

    // MARK: Private
    
    private let api = TraktAPI()
}
