import SwiftUI

struct ActorGroupListView: View {
    let title: String
    let actors: [Actor]

    var body: some View {
        NavigationStack {
            List(actors) { actor in
                NavigationLink(value: actor) {
                    HStack {
                        Image(actor.roles.first?.imageName ?? "placeholder")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                        
                        VStack(alignment: .leading) {
                            Text(actor.name)
                                .font(.headline)
                            Text(actor.band)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle(title)
            .navigationDestination(for: Actor.self) { actor in
                ActorDetailView(actor: actor)
            }
        }
    }
}
