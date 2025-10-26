import SwiftUI
import AVKit

struct UniverseView: View {
    @State private var expanded: Set<UUID> = []
    private let data = DataManager.shared
    
    // 建立循環播放的背景播放器
    @State private var player: AVQueuePlayer = AVQueuePlayer()
    @State private var looper: AVPlayerLooper?
    
    var body: some View {
        ZStack {
            // 背景影片層（改用等比裁切填滿）
            VideoBackgroundView(player: $player, looper: $looper, resourceName: "sliversky", fileExtension: "mp4")
                .ignoresSafeArea()
                .allowsHitTesting(false)
            
            // 內容層
            List {
                Section("世界觀與名詞解釋") {
                    ForEach(data.worldviewIntros) { item in
                        UniverseIntroRow(item: item, expanded: $expanded)
                            .listRowBackground(Color.clear)
                    }
                }
                .listRowSeparator(.hidden)
            }
            .scrollContentBackground(.hidden) // 讓列表背景透明
            // 加強可讀性：更深的半透明黑遮罩 + 白色文字
            .foregroundStyle(.white)
            .tint(.white)
            .navigationTitle("終極宇宙")
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .onAppear {
            player.play()
        }
        .onDisappear {
            player.pause()
        }
    }
}

// 以 AVPlayerLayer 實現等比裁切填滿（resizeAspectFill）
private struct PlayerContainerView: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: Context) -> PlayerView {
        let view = PlayerView()
        view.player = player
        return view
    }
    
    func updateUIView(_ uiView: PlayerView, context: Context) {
        uiView.player = player
    }
    
    final class PlayerView: UIView {
        override static var layerClass: AnyClass { AVPlayerLayer.self }
        var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
        var player: AVPlayer? {
            get { playerLayer.player }
            set {
                playerLayer.player = newValue
                playerLayer.videoGravity = .resizeAspectFill // 重要：裁切填滿
            }
        }
    }
}

private struct VideoBackgroundView: View {
    @Binding var player: AVQueuePlayer
    @Binding var looper: AVPlayerLooper?
    
    let resourceName: String
    let fileExtension: String? // 若放在 Asset Catalog 的 Video set，可傳 nil，否則像 "mp4"
    
    var body: some View {
        GeometryReader { proxy in
            PlayerContainerView(player: player)
                .disabled(true)
                .onAppear {
                    configureLoopIfNeeded()
                    // 靜音避免影響使用者
                    player.isMuted = true
                }
                .onChange(of: proxy.size) { _, _ in
                    // 對旋轉/尺寸改變保持穩定播放
                    if player.timeControlStatus == .paused {
                        player.play()
                    }
                }
                .background(Color.black)
        }
    }
    
    private func configureLoopIfNeeded() {
        guard looper == nil else { return }
        
        // 直接從主 Bundle 以指定副檔名載入
        if let url = Bundle.main.url(forResource: resourceName, withExtension: fileExtension) {
            let asset = AVURLAsset(url: url)
            let item = AVPlayerItem(asset: asset)
            let queue = AVQueuePlayer(items: [item])
            self.player = queue
            self.looper = AVPlayerLooper(player: queue, templateItem: item)
            return
        }
        
        // 次選：若未提供副檔名或找不到，嘗試以 mp4
        if let url = Bundle.main.url(forResource: resourceName, withExtension: fileExtension ?? "mp4") {
            let asset = AVAsset(url: url)
            let item = AVPlayerItem(asset: asset)
            let queue = AVQueuePlayer(items: [item])
            self.player = queue
            self.looper = AVPlayerLooper(player: queue, templateItem: item)
        } else {
            // 找不到影片資源時，保持黑背景
        }
    }
}

private struct UniverseIntroRow: View {
    let item: TimeSpaceIntro
    @Binding var expanded: Set<UUID>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title = item.title {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            HStack(alignment: .firstTextBaseline) {
                Text(item.summary)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(1)
                    .truncationMode(.tail)
                Spacer()
                Button {
                    toggle(item.id)
                } label: {
                    Image(systemName: expanded.contains(item.id) ? "chevron.up" : "chevron.down")
                        .font(.footnote)
                        .foregroundStyle(.white)
                }
                .buttonStyle(.borderless)
            }
            if expanded.contains(item.id) {
                Text(item.details)
                    .font(.body)
                    .foregroundColor(.white)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut) {
                toggle(item.id)
            }
        }
        .background(Color.clear)
    }
    
    private func toggle(_ id: UUID) {
        if expanded.contains(id) {
            expanded.remove(id)
        } else {
            expanded.insert(id)
        }
    }
}
