import SwiftUI

struct LaunchView: View {
    
    @Binding var authModel: AuthenticationManager
    
    init(authModel: Binding<AuthenticationManager> = .constant(AuthenticationManager())) {
        self._authModel = authModel
    }
    
    var body: some View {
        if authModel.isLoggedIn {
            HomeView()
        } else {
            AuthenticationView(model: $authModel)
        }
    }
}

struct HomeView: View {
    var body: some View {
        Text("Home View")
    }
}

#Preview {
    LaunchView()
}
