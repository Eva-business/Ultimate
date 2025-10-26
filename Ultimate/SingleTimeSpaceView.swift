import SwiftUI

struct SingleTimeSpaceView: View {
    let space: TimeSpace
    @State private var expanded: Set<UUID> = [] // 控制展開的集合
    
    // 選取的角色與顯示其他角色的 sheet 開關
    @State private var selectedRole: Role? = nil
    @State private var showOtherRolesSheet: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 標題
                Text(space.name)
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(space.themeColor)
                    .padding(.top)
                
                // 多個介紹區塊（含金時空三個系列）
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(space.intros) { intro in
                        introBlock(intro)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
                    }
                }
                .padding(.horizontal)
                
                // 人物關係圖（每個時空自己的網址）
                if !space.relationGraphs.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("人物關係圖")
                            .font(.title2)
                            .bold()
                            .padding(.top)
                        
                        ForEach(space.relationGraphs) { graph in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(graph.title)
                                    .font(.headline)
                                    .padding(.leading, 4)
                                
                                WebView(url: graph.url)
                                    .frame(height: 400)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .shadow(radius: 4)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // 角色介紹（橫向滑動卡片）
                if !space.relatedRoles.isEmpty {
                    Text("角色介紹")
                        .font(.title2)
                        .bold()
                        .padding(.top)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 16) {
                            ForEach(space.relatedRoles) { role in
                                RoleCardView(role: role)
                                    .onTapGesture {
                                        withAnimation(.spring()) {
                                            if selectedRole?.id == role.id {
                                                // 再次點選即取消選取
                                                selectedRole = nil
                                            } else {
                                                selectedRole = role
                                            }
                                        }
                                    }
                                    .scaleEffect(selectedRole?.id == role.id ? 1.03 : 1.0)
                                    .animation(.easeInOut(duration: 0.2), value: selectedRole?.id)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                    
                    // 選取角色後的詳細介紹面板
                    if let role = selectedRole {
                        roleDetailPanel(for: role)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                            .padding(.horizontal)
                    }
                } else {
                    Text("此時空角色資料尚未建立")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            .padding(.bottom, 60)
        }
        .background(space.themeColor.opacity(0.05))
        .sheet(isPresented: $showOtherRolesSheet) {
            if let role = selectedRole {
                OtherRolesSheetView(selectedRole: role)
            }
        }
    }
    
    @ViewBuilder
    private func introBlock(_ intro: TimeSpaceIntro) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // 標題（可選）
            if let title = intro.title {
                Text(title)
                    .font(.headline)
            }
            
            // 摘要 + 展開按鈕
            HStack(alignment: .firstTextBaseline) {
                Text(intro.summary)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Spacer()
                Button {
                    toggle(intro.id)
                } label: {
                    Label(expanded.contains(intro.id) ? "收合" : "展開", systemImage: expanded.contains(intro.id) ? "chevron.up" : "chevron.down")
                        .labelStyle(.titleAndIcon)
                        .font(.footnote)
                }
                .buttonStyle(.borderless)
            }
            
            // 詳細內容（展開時顯示）
            if expanded.contains(intro.id) {
                Text(intro.details)
                    .font(.body)
                    .foregroundColor(.primary)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut) {
                toggle(intro.id)
            }
        }
        .animation(.easeInOut, value: expanded)
    }
    
    private func toggle(_ id: UUID) {
        if expanded.contains(id) {
            expanded.remove(id)
        } else {
            expanded.insert(id)
        }
    }
    
    // MARK: - 詳細面板
    @ViewBuilder
    private func roleDetailPanel(for role: Role) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(role.characterName)
                        .font(.title3).bold()
                    Text("\(role.series) ｜ \(role.timeSpace)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button {
                    showOtherRolesSheet = true
                } label: {
                    Label("查看其他分身", systemImage: "person.crop.square.filled.and.at.rectangle")
                        .font(.footnote)
                }
                .buttonStyle(.borderedProminent)
            }
            
            if !role.quote.isEmpty {
                Text("「\(role.quote)」")
                    .italic()
                    .foregroundColor(.secondary)
            }
            
            Text(role.story)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
    }
}

// MARK: - 其他角色 Sheet
private struct OtherRolesSheetView: View {
    let selectedRole: Role
    
    // 當前 sheet 中再次點擊的角色
    @State private var tappedOtherRole: Role? = nil
    @State private var showNestedDetailSheet: Bool = false
    
    private var actorAndOtherRoles: (actor: Actor, roles: [Role])? {
        // 找到包含 selectedRole 的演員
        let dm = DataManager.shared
        guard let actor = dm.actors.first(where: { $0.roles.contains(where: { $0.id == selectedRole.id }) }) else {
            return nil
        }
        let others = actor.roles.filter { $0.id != selectedRole.id }
        return (actor, others)
    }
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Group {
                if let data = actorAndOtherRoles {
                    let sectionTitle: String = "\(data.actor.name) 的其他角色"
                    List {
                        Section(sectionTitle) {
                            ForEach(data.roles) { role in
                                Button {
                                    tappedOtherRole = role
                                    showNestedDetailSheet = true
                                } label: {
                                    OtherRoleRow(role: role)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text("找不到此演員的其他角色")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
            }
            .navigationTitle("其他角色")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("關閉") { dismiss() }
                }
            }
        }
        // 次級 sheet：顯示列表中被點擊角色的詳細資訊
        .sheet(isPresented: $showNestedDetailSheet) {
            if let role = tappedOtherRole {
                NestedRoleDetailSheet(role: role)
            }
        }
    }
}

private struct OtherRoleRow: View {
    let role: Role
    var body: some View {
        HStack(spacing: 12) {
            Image(role.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 4) {
                Text(role.characterName).bold()
                Text("\(role.series) ｜ \(role.timeSpace)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// 次級詳細資訊 sheet，沿用主畫面的資訊風格，並可再查看該演員其他角色
private struct NestedRoleDetailSheet: View {
    let role: Role
    @State private var showOtherRoles: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Image(role.imageName)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(role.characterName)
                            .font(.title2).bold()
                        Text("\(role.series) ｜ \(role.timeSpace)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if !role.quote.isEmpty {
                            Text("「\(role.quote)」")
                                .italic()
                                .foregroundColor(.secondary)
                        }
                        
                        Text(role.story)
                            .font(.body)
                    }
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
                    
                }
                .padding()
            }
            .navigationTitle("角色詳情")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("關閉") { dismiss() }
                }
            }
        }
        .sheet(isPresented: $showOtherRoles) {
            OtherRolesSheetView(selectedRole: role)
        }
    }
    
    @Environment(\.dismiss) private var dismiss
}
