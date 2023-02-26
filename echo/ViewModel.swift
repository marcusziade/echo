import SwiftUI
import Combine
import WebKit

@MainActor final class ViewModel: ObservableObject {
    @Published var movies: [String] = []
    @Published var isError: Bool = false
    @Published var errorMessage: String?
    @Published var authCode: String?
    @Published var showSignIn: Bool = false
    
    private let api = TraktAPI()
    
    func authorize() async {
        do {
            let success = try await api.authorize(authCode: authCode ?? "")
            isError = !success
        } catch {
            isError = true
            errorMessage = error.localizedDescription
        }
    }
    
    func getPopularMovies() async {
        do {
            movies = try await api.getPopularMovies()
        } catch {
            isError = true
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: Private
    
    private var cancellables = Set<AnyCancellable>()
}
