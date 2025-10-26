import SwiftUI

struct RoleCardView: View {
    let role: Role
    
    var body: some View {
        VStack {
            Image(role.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            
            Text(role.characterName)
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(maxWidth: .infinity)
            
            Text("\(role.quote)")
                .italic()
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .padding()
        .frame(width: 350) // ✅ 固定卡片寬度
        .background(Color(.systemGray6))
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}
