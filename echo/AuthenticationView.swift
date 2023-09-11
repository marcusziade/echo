import Foundation
import SwiftUI

struct AuthenticationView: View {
    
    @Binding var model: AuthenticationManager
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(
                    colors: [.blue, .purple]
                ),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Welcome to Echo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.bottom, 50)
                    .shadow(color: .black, radius: 5)
                
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
            .padding()
            .alert("Error", isPresented: $model.isError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(model.errorMessage ?? "An unknown error occurred.")
            }
            .sheet(isPresented: $model.showSignIn) {
                NavigationView {
                    WebView(didReceiveCode: { code in
                        model.authCode = code
                        model.showSignIn = false
                    }, request: URLRequest(url: URL(string: "https://trakt.tv/oauth/authorize?response_type=code&client_id=\(Keys.clientId)&redirect_uri=\(Keys.redirectUri)")!))
                    .navigationBarItems(leading: Button {
                        model.showSignIn = false
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color.primary)
                    })
                }
            }
        }
    }
}
