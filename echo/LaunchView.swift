import SwiftUI

struct LaunchView: View {
    
    @Binding var model: AuthenticationVM
    
    init(model: Binding<AuthenticationVM> = .constant(.init())) {
        self._model = model
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
            VStack {
                welcomeLabel
                authButton
            }
            .padding()
            .alert("Error", isPresented: $model.isError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(model.errorMessage ?? "An unknown error occurred.")
            }
            .sheet(isPresented: $model.showSignIn) {
                NavigationView {
                    authWebView
                }
            }
        }
    }
    
    // MARK: Private
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [.blue, .purple]),
            startPoint: .top,
            endPoint: .bottom
        )
        .edgesIgnoringSafeArea(.all)
    }
    
    private var welcomeLabel: some View {
        Text("Welcome to Echo")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.bottom, 50)
            .shadow(color: .black, radius: 5)
    }
    
    private var authButton: some View {
        Button {
            model.showSignIn = true
            Task {
                await model.authorize()
            }
        } label: {
            Text("Authenticate")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding()
                .background(Capsule().fill(Color.white.opacity(0.5)))
                .overlay(Capsule().stroke(Color.white, lineWidth: 1))
        }
        .padding(20)
        .scaleEffect(model.animationAmount)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 0.7)
                .repeatForever(autoreverses: true)
            ) {
                model.animationAmount = 1.05
            }
        }
    }
    
    private var authWebView: some View {
        WebView(didReceiveCode: { code in
            model.authCode = code
            model.showSignIn = false
            model.isLoggedIn = true
        }, request: URLRequest(url: URL(string: "https://trakt.tv/oauth/authorize?response_type=code&client_id=\(Keys.clientID)&redirect_uri=\(Keys.redirectURI)")!))
        .navigationBarItems(leading: Button {
            model.showSignIn = false
        } label: {
            Image(systemName: "xmark")
                .foregroundStyle(Color.primary)
        })
    }
}

#Preview {
    LaunchView()
}
