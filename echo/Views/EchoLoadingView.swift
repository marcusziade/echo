import SwiftUI

struct LoadingSpinner: View {
    
    @State private var isSpinning = false
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 8)
                .fill(Color.gray.opacity(0.5))
            
            Image(systemName: "film")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .rotationEffect(.degrees(isSpinning ? 360 : 0))
                .animation(
                    .linear(duration: 2)
                    .repeatForever(autoreverses: false),
                    value: isSpinning
                )
                .onAppear() {
                    isSpinning = true
                }
        }
        .frame(width: 100, height: 100)
    }
}

#Preview {
    LoadingSpinner()
}
