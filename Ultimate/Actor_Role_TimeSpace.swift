import SwiftUI

struct Actor: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let band: String
    let roles: [Role]
    
    static func == (lhs: Actor, rhs: Actor) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Role: Identifiable {
    let id = UUID()
    let characterName: String
    let timeSpace: String
    let series: String
    let imageName: String
    let quote: String
    let story: String
}

struct TimeSpaceIntro: Identifiable {
    let id = UUID()
    let title: String?       // 可為 nil，非金時空可不顯示標題
    let summary: String      // 一句話摘要
    let details: String      // 點擊展開的詳細介紹
}

struct TimeSpace: Identifiable {
    let id = UUID()
    let name: String
    let intros: [TimeSpaceIntro]
    let themeColor: Color
    let relatedRoles: [Role]
    
    // 改這裡
    let relationGraphs: [RelationGraph]
}

struct RelationGraph: Identifiable {
    let id = UUID()
    let title: String
    let url: URL
}


