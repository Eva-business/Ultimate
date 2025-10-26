import SwiftUI

struct ContentView: View {
    @State private var currentPage: Page = .home
    @State private var topOffset: CGFloat = 0
    @State private var bottomOffset: CGFloat = 0
    
    let threshold: CGFloat = 100
    
    enum Page {
        case home, timeSpace, actor
    }
    
    var body: some View {
        ZStack {
            // 首頁
            if currentPage == .home {
                VStack(spacing: 0) {
                    // 時空篇
                    SectionView(title: "時空篇", color: .red)
                        .overlay(Text("請往下拉").foregroundColor(.white).bold().padding(.top, 20), alignment: .top)
                        .offset(y: topOffset)
                        .zIndex(topOffset > 0 ? 1 : 0) // 拖動時置頂
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if value.translation.height > 0 { topOffset = value.translation.height }
                                }
                                .onEnded { value in
                                    if value.translation.height > threshold {
                                        withAnimation(.easeOut(duration: 0.3)) { topOffset = UIScreen.main.bounds.height }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            withAnimation { currentPage = .timeSpace }
                                            topOffset = 0
                                        }
                                    } else {
                                        withAnimation(.spring()) { topOffset = 0 }
                                    }
                                }
                        )
                    
                    // 人物篇
                    SectionView(title: "人物篇", color: .blue)
                        .overlay(Text("請往上拉").foregroundColor(.white).bold().padding(.bottom, 20), alignment: .bottom)
                        .offset(y: bottomOffset)
                        .zIndex(bottomOffset < 0 ? 1 : 0) // 拖動時置頂
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if value.translation.height < 0 { bottomOffset = value.translation.height }
                                }
                                .onEnded { value in
                                    if value.translation.height < -threshold {
                                        withAnimation(.easeOut(duration: 0.3)) { bottomOffset = -UIScreen.main.bounds.height }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            withAnimation { currentPage = .actor }
                                            bottomOffset = 0
                                        }
                                    } else {
                                        withAnimation(.spring()) { bottomOffset = 0 }
                                    }
                                }
                        )
                }
                .transition(.opacity)
            }
            
            // 時空篇詳細頁
            if currentPage == .timeSpace {
                TimeSpaceView()
                    .transition(.move(edge: .top))
                    .zIndex(2)
                    .overlay(
                        Button(action: { withAnimation { currentPage = .home } }) {
                            Text("回首頁")
                                .padding(10)
                                .background(Color.black.opacity(0.6))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(), alignment: .topTrailing // 固定右上角
                    )
            }
            
            // 人物篇詳細頁
            if currentPage == .actor {
                ActorView()
                    .transition(.move(edge: .bottom))
                    .zIndex(2)
                    .overlay(
                        Button(action: { withAnimation { currentPage = .home } }) {
                            Text("回首頁")
                                .padding(10)
                                .background(Color.black.opacity(0.6))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(), alignment: .topTrailing // 固定右上角
                    )
            }
        }
        .animation(.easeInOut, value: currentPage)
    }
}

#Preview {
    ContentView()
}
