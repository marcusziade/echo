import SwiftUI
import WebKit

struct ContentView: View {
    @StateObject private var model = ViewModel()
    
    var body: some View {
        VStack {
            List(model.movies, id: \.self) { movie in
                Text(movie)
            }
            
            Button("Authorize") {
                model.showSignIn = true
                Task {
                    await model.authorize()
                }
            }
            .buttonStyle(.borderedProminent)
            
            Button("Get Popular Movies") {
                Task {
                    await model.getPopularMovies()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .alert("Error", isPresented: $model.isError) {
            Text(model.errorMessage ?? "Unknown error")
        }
        .sheet(isPresented: $model.showSignIn) {
            WebView(didReceiveCode: { code in
                model.authCode = code
                model.showSignIn = false
            }, request: URLRequest(url: URL(string: "https://trakt.tv/oauth/authorize?response_type=code&client_id=\(Keys.clientId)&redirect_uri=\(Keys.redirectUri)")!))
            .edgesIgnoringSafeArea(.all)
        }
    }
}
