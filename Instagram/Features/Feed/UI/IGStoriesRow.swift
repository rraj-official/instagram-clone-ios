import SwiftUI

struct IGStoryCircle: View {
    let imageURL: String?
    let name: String
    let isMyStory: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .bottomTrailing) {
                // Main Concentric Circles Group
                ZStack(alignment: .center) {
                    // Ring
                    Circle()
                        .stroke(isMyStory ? Color.clear : Color.clear, lineWidth: 2) // Placeholder for sizing
                        .background(
                            isMyStory 
                            ? AnyView(Color.clear) 
                            : AnyView(IGGradients.storyRing.clipShape(Circle()))
                        )
                        .frame(width: IGTheme.Layout.storyRingSize, height: IGTheme.Layout.storyRingSize)
                    
                    // Avatar (White/Black border gap)
                    Circle()
                        .fill(Color.igBackground)
                        .frame(width: IGTheme.Layout.storyRingSize - 4, height: IGTheme.Layout.storyRingSize - 4)
                    
                    // Image
                    if let urlString = imageURL, let url = URL(string: urlString) {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image.resizable().scaledToFill()
                            } else {
                                Color.gray
                            }
                        }
                        .frame(width: IGTheme.Layout.storyAvatarSize, height: IGTheme.Layout.storyAvatarSize)
                        .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: IGTheme.Layout.storyAvatarSize, height: IGTheme.Layout.storyAvatarSize)
                    }
                }
                
                // Plus badge for "Your Story"
                if isMyStory {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .foregroundColor(.blue)
                            .frame(width: 22, height: 22)
                    }
                    .offset(x: 5, y: 5)
                }
            }
            
            Text(name)
                .font(IGTypography.storyLabel())
                .foregroundColor(.igPrimaryText)
                .lineLimit(1)
                .frame(width: 70)
        }
    }
}

struct IGStoriesRow: View {
    // We can accept some user data here, or just mock it for visual
    // Since we don't have a specific Story API, let's derive it from the feed posts
    // or just mock "Your Story" + generic users.
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                // My Story
                IGStoryCircle(
                    imageURL: "https://i.pravatar.cc/150?u=0", 
                    name: "Your story", 
                    isMyStory: true
                )
                
                // Mock other stories with real-ish names
                let storyUsers = [
                    ("john_doe", "https://i.pravatar.cc/150?u=1"),
                    ("jane_smith", "https://i.pravatar.cc/150?u=2"),
                    ("alex_jones", "https://i.pravatar.cc/150?u=3"),
                    ("emma_brown", "https://i.pravatar.cc/150?u=4"),
                    ("michael_clark", "https://i.pravatar.cc/150?u=5"),
                    ("olivia_davis", "https://i.pravatar.cc/150?u=6"),
                    ("william_moore", "https://i.pravatar.cc/150?u=7"),
                    ("sophia_taylor", "https://i.pravatar.cc/150?u=8"),
                    ("james_anderson", "https://i.pravatar.cc/150?u=9")
                ]
                
                ForEach(storyUsers, id: \.0) { user in
                    IGStoryCircle(
                        imageURL: user.1, 
                        name: user.0, 
                        isMyStory: false
                    )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color.igBackground)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.igSeparator),
            alignment: .bottom
        )
    }
}

