import SwiftUI

struct TimeSpaceView: View {
    let data = DataManager.shared
    
    // Track the current tab selection
    @State private var selection: TimeSpaceTab = .gold
    // Control showing the transition overlay
    @State private var showTransition: Bool = false
    // Internal animation state for the overlay
    @State private var transitionPhase: SwirlPhase = .idle
    
    var body: some View {
        NavigationStack {
            ZStack {
                TabView(selection: $selection) {
                    // 金時空
                    SingleTimeSpaceView(space: data.timeSpaces.first { $0.name == "金時空" } ?? placeholderSpace(name: "金時空"))
                        .tag(TimeSpaceTab.gold)
                        .tabItem {
                            Label("金時空", systemImage: "sun.max.fill")
                        }
                    
                    // 銀時空
                    SingleTimeSpaceView(space: data.timeSpaces.first { $0.name == "銀時空" } ?? placeholderSpace(name: "銀時空"))
                        .tag(TimeSpaceTab.silver)
                        .tabItem {
                            Label("銀時空", systemImage: "moon.stars.fill")
                        }
                    
                    // 銅時空
                    SingleTimeSpaceView(space: data.timeSpaces.first { $0.name == "銅時空" } ?? placeholderSpace(name: "銅時空"))
                        .tag(TimeSpaceTab.copper)
                        .tabItem {
                            Label("銅時空", systemImage: "sparkles")
                        }
                    
                    // 鐵時空
                    SingleTimeSpaceView(space: data.timeSpaces.first { $0.name == "鐵時空" } ?? placeholderSpace(name: "鐵時空"))
                        .tag(TimeSpaceTab.iron)
                        .tabItem {
                            Label("鐵時空", systemImage: "shield.lefthalf.fill")
                        }
                    
                    // 終極宇宙（世界觀）第五分頁
                    UniverseView()
                        .tag(TimeSpaceTab.universe)
                        .tabItem {
                            Label("終極宇宙", systemImage: "globe.asia.australia.fill")
                        }
                }
                .onChange(of: selection) { _, _ in
                    triggerTransition()
                }
                
                // Full-screen swirl + black→white flash overlay
                if showTransition {
                    SwirlTransitionOverlay(phase: transitionPhase)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .onAppear {
                            playSwirlAnimation()
                        }
                }
            }
        }
    }
    
    // MARK: - Transition control
    private func triggerTransition() {
        guard !showTransition else { return }
        transitionPhase = .idle
        showTransition = true
    }
    
    private func playSwirlAnimation() {
        // Phase timings tuned for a cinematic feel (~1.0s total)
        withAnimation(.easeIn(duration: 0.15)) {
            transitionPhase = .appearBlack
        }
        // Start swirl growth/rotation while still dark
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.easeInOut(duration: 0.4)) {
                transitionPhase = .swirlGrow
            }
        }
        // Flash to intense white
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.52) {
            withAnimation(.easeOut(duration: 0.22)) {
                transitionPhase = .flashWhite
            }
        }
        // Fade out overlay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeOut(duration: 0.2)) {
                transitionPhase = .fadeOut
            }
        }
        // Remove overlay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.02) {
            showTransition = false
            transitionPhase = .idle
        }
    }
}

// MARK: - 預設空白資料避免崩潰
func placeholderSpace(name: String) -> TimeSpace {
    let intro = TimeSpaceIntro(
        title: nil,
        summary: "尚未加入資料",
        details: ""
    )
    return TimeSpace(
        name: name,
        intros: [intro],
        themeColor: .gray,
        relatedRoles: [],
        relationGraphs: [] // 空陣列，符合 [RelationGraph]
    )
}

// MARK: - Tab enum
private enum TimeSpaceTab: Hashable {
    case gold, silver, copper, iron, universe
}

// MARK: - Swirl Overlay

private enum SwirlPhase: Equatable {
    case idle
    case appearBlack       // black background appears
    case swirlGrow         // swirl expands and rotates
    case flashWhite        // final white flash (very bright)
    case fadeOut           // overlay fades out
}

private struct SwirlTransitionOverlay: View {
    let phase: SwirlPhase
    
    var body: some View {
        ZStack {
            // Background: black to white depending on phase
            backgroundColor
                .animation(.linear(duration: 0.2), value: phase)
            
            // Swirl vortex in the center (multi-ring)
            SwirlVortexView(phase: phase)
                .allowsHitTesting(false)
            
            // Extra bloom/flash layer to simulate eye-searing exit
            if phase == .flashWhite || phase == .fadeOut {
                Color.white
                    .opacity(phase == .flashWhite ? 1.0 : 0.65)
                    .blendMode(.plusLighter)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
    }
    
    private var backgroundColor: Color {
        switch phase {
        case .idle:
            return .clear
        case .appearBlack, .swirlGrow:
            return .black
        case .flashWhite, .fadeOut:
            return .white
        }
    }
}

// MARK: - Multi-ring Swirl Vortex

private struct SwirlVortexView: View {
    let phase: SwirlPhase
    
    // Configuration: number of rings and spacing
    private let ringCount: Int = 5
    private let baseSizeRatio: CGFloat = 0.9
    
    // Derived animation parameters
    private var baseRotation: Angle {
        switch phase {
        case .idle:        return .degrees(0)
        case .appearBlack: return .degrees(120)
        case .swirlGrow:   return .degrees(720)   // 2 turns across growth
        case .flashWhite:  return .degrees(900)   // 2.5 turns
        case .fadeOut:     return .degrees(900)
        }
    }
    private var baseScale: CGFloat {
        switch phase {
        case .idle:        return 0.08
        case .appearBlack: return 0.25
        case .swirlGrow:   return 1.8
        case .flashWhite:  return 2.6
        case .fadeOut:     return 3.2
        }
    }
    private var baseOpacity: CGFloat {
        switch phase {
        case .idle:        return 0
        case .appearBlack: return 0.85
        case .swirlGrow:   return 1.0
        case .flashWhite:  return 0.5
        case .fadeOut:     return 0.0
        }
    }
    
    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height) * baseSizeRatio
            ZStack {
                ForEach(0..<ringCount, id: \.self) { idx in
                    let progress = CGFloat(idx) / CGFloat(max(1, ringCount - 1))
                    
                    // Each ring slightly smaller and phase-offset to create a complex vortex
                    let ringScale = baseScale * (0.65 + 0.35 * progress)
                    let ringOpacity = baseOpacity * (0.35 + 0.65 * (1 - progress))
                    let ringRotation = baseRotation + .degrees(Double(progress) * 180) // offset per ring
                    
                    Circle()
                        .fill(swirlGradient(for: progress))
                        .frame(width: size, height: size)
                        .scaleEffect(ringScale)
                        .rotationEffect(ringRotation)
                        .opacity(ringOpacity)
                        .blendMode(.screen)
                        .shadow(color: .white.opacity(0.2 * (1 - progress)), radius: 8, x: 0, y: 0)
                }
                
                // Inner glow to enhance the “hole”
                Circle()
                    .fill(innerGlow)
                    .frame(width: size * 0.4, height: size * 0.4)
                    .scaleEffect(baseScale * 0.9)
                    .opacity(baseOpacity * 0.9)
                    .blur(radius: 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .animation(.easeInOut(duration: 0.4), value: phase)
    }
    
    // Angular gradient with multiple alternating bands; tint varies slightly by ring
    private func swirlGradient(for progress: CGFloat) -> AngularGradient {
        // Define opacity bands (0...1). Zero means a gap (clear).
        let opacities: [Double] = [
            0.0,
            0.18,
            0.0,
            0.28,
            0.0,
            0.38,
            0.0,
            0.48,
            0.0,
            0.6
        ]
        // Subtle tint shift per ring (cooler inner, warmer outer)
        let tint = Color(hue: 0.58 - 0.08 * Double(progress), saturation: 0.1, brightness: 1.0)
        let tinted: [Color] = opacities.map { alpha in
            alpha == 0 ? .clear : tint.opacity(alpha)
        }
        
        return AngularGradient(
            gradient: Gradient(colors: tinted),
            center: .center
        )
    }
    
    private var innerGlow: RadialGradient {
        RadialGradient(
            gradient: Gradient(colors: [
                .white.opacity(0.95),
                .white.opacity(0.25),
                .clear
            ]),
            center: .center,
            startRadius: 0,
            endRadius: 140
        )
    }
}
