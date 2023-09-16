import SwiftUI

struct PopularMoviesView: View {
    
    @Binding var model: PopularMoviesVM
    
    var body: some View {
        switch model.state {
        case .result(let movies):
            NavigationView {
                List(movies, id: \.self) { movie in
                    Text(movie)
                }
                .navigationTitle("Popular Movies")
            }
        case .loading:
            LoadingSpinner()
        case .error:
            Text("An error occurred.")
        }
    }
}

#Preview {
    let model = PopularMoviesVM(traktAPI: Mock_TraktAPI())
    return PopularMoviesView(model: .constant(model))
}
