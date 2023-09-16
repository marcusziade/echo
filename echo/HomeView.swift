import Foundation
import SwiftUI

struct HomeView: View {
    
    @Binding var authModel: AuthenticationVM
    
    init(authModel: Binding<AuthenticationVM> = .constant(.init())) {
        _authModel = authModel
    }
    
    var body: some View {
        if authModel.isLoggedIn {
            NavigationView {
                TabView {
                    PopularMoviesView(
                        model: .constant(
                            PopularMoviesVM(traktAPI: authModel.api)
                        )
                    )
                    .tabItem {
                        Image(systemName: "film")
                        Text("Popular")
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Logout", action: authModel.deauthorize)
                    }
                }
            }
        } else {
            LaunchView(model: $authModel)
        }
    }
}
