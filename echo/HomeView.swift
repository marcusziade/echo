import Foundation
import SwiftUI

struct HomeView: View {
    
    @Binding var authModel: AuthenticationVM
    
    init(authModel: Binding<AuthenticationVM> = .constant(.init())) {
        self._authModel = authModel
    }
    
    var body: some View {
        Button {
            authModel.deauthorize()
        } label: {
            Text("Sign Out")
        }
    }
}
