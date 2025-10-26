import SwiftUI

struct ActorDetailView: View {
    let actor: Actor
    
    var body: some View {
        VStack {
            Text(actor.name)
                .font(.largeTitle)
                .bold()
                .padding(.top)
            
            // 滑動顯示角色
            TabView {
                ForEach(actor.roles) { role in
                    VStack(spacing: 15) {
                        Image(role.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .shadow(radius: 5)
                            .transition(.slide)
                        
                        Text(role.characterName)
                            .font(.title2)
                            .bold()
                        
                        Text("所屬時空：\(role.timeSpace)")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Text("「\(role.quote)」")
                            .italic()
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        // ✅ 可上下滑動的故事區塊
                        ScrollView {
                            Text(role.story)
                                .padding()
                                .multilineTextAlignment(.leading)
                        }
                        .frame(height: 150) // 你可以調整高度
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .shadow(radius: 2)
                        .padding(.horizontal)
                    }
                    .padding()
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .navigationTitle(actor.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
