import SwiftUI

struct SectionView: View {
    let title: String
    let color: Color
    
    var body: some View {
        ZStack {
            color.opacity(0.8).ignoresSafeArea()
            Text(title)
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
                .shadow(radius: 5)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transition(.opacity)
    }
}
