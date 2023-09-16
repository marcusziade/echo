import Foundation
import SwiftUI
import Observation

@main
struct Echo_App: App {
    
    let authModel = AuthenticationVM()
    
    var body: some Scene {
        WindowGroup {
            HomeView(authModel: .constant(authModel))
        }
    }
}
