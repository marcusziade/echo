import Foundation
import Observation

@Observable final class PopularMoviesVM {
    
    enum State {
        case result(movies: [String])
        case loading
        case error
    }
    
    var state: State = .loading
    
    init(traktAPI: TraktAPIProtocol = TraktAPI()) {
        self.traktAPI = traktAPI
        
        Task { await getPopularMovies() }
    }
    
    func getPopularMovies() async {
        state = .loading
        
        traktAPI.authorize { [unowned self] result in
            switch result {
            case .success(_):
                Task {
                    do {
                        let movies = try await traktAPI.getPopularMovies()
                        state = .result(movies: movies)
                    } catch {
                        print("Error fetching movies: \(error)")
                        state = .error
                    }
                }
            case .failure(let failure):
                print("Error authorizing: \(failure)")
                state = .error
            }
        }
    }
    
    // MARK: Private
    
    private let traktAPI: TraktAPIProtocol
}
