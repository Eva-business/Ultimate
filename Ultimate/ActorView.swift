import SwiftUI

struct ActorView: View {
    let data = DataManager.shared
    
    var body: some View {
        TabView {
            ActorGroupListView(title: "飛輪海", actors: data.actors.filter { $0.band == "飛輪海" })
                        .tabItem {
                            Label("飛輪海", systemImage: "flame.fill")
                        }

            ActorGroupListView(title: "武虎將", actors: data.actors.filter { $0.band == "武虎將" })
                        .tabItem {
                            Label("武虎將", systemImage: "pawprint.fill")
                        }

            ActorGroupListView(title: "東城衞", actors: data.actors.filter { $0.band == "東城衞" })
                        .tabItem {
                            Label("東城衞", systemImage: "guitars")
                        }

            ActorGroupListView(title: "強辯", actors: data.actors.filter { $0.band == "強辯" })
                        .tabItem {
                            Label("強辯", systemImage: "tuningfork")
                        }

            ActorGroupListView(title: "SpeXial", actors: data.actors.filter { $0.band == "SpeXial" })
                        .tabItem {
                            Label("SpeXial", systemImage: "star.circle.fill")
                        }

            ActorGroupListView(title: "A'N'D", actors: data.actors.filter { $0.band == "A'N'D" })
                        .tabItem {
                            Label("A'N'D", systemImage: "music.mic")
                        }

            ActorGroupListView(title: "其他", actors: data.actors.filter {
                        // 修正排除清單，使其與資料中的 band 名稱完全一致
                        !["飛輪海", "武虎將", "東城衞", "強辯", "SpeXial", "A'N'D"].contains($0.band)
                    })
                    .tabItem {
                        Label("其他", systemImage: "person.3.fill")
                    }
                }
            }
        }
