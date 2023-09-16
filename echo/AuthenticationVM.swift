import Foundation
import Combine
import Observation

@Observable final class AuthenticationVM {
    var animationAmount: CGFloat = 1
    var showSignIn: Bool = false
    var isError: Bool = false
    var errorMessage: String?
    var isLoggedIn = false
    
    init() {
        Task { await authorize() }
    }
    
    private(set) var api = TraktAPI()
    
    func authorize() async {
        api.authorize { [unowned self] result in
            switch result {
            case .success:
                isLoggedIn = api.isLoggedIn
                isError = false
            case .failure(let error):
                isError = true
                errorMessage = error.localizedDescription
            }
        }
    }

    func deauthorize() {
        api.deauthorize()
        isLoggedIn = false
    }
}
