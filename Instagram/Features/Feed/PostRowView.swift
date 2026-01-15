import SwiftUI

struct PostRowView: View {
    @ObservedObject var post: PostEntity
    let onLikeTapped: () -> Void
    
    @State private var isHeartOverlayVisible = false
    @State private var isHeartAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Header
            HStack {
                // Avatar
                AsyncImage(url: URL(string: post.userImageURL ?? "")) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        Color.gray
                    }
                }
                .frame(width: IGTheme.Layout.avatarSizeSmall, height: IGTheme.Layout.avatarSizeSmall)
                .clipShape(Circle())
                
                // Username
                Text(post.userName ?? "Unknown")
                    .font(IGTypography.username())
                    .foregroundColor(.igPrimaryText)
                
                Spacer()
                
                // More Button
                IGIcon(.more, size: 20)
            }
            .padding(.horizontal, IGTheme.Spacing.xs)
            .padding(.vertical, IGTheme.Spacing.xs)
            
            // MARK: - Media (Double Tap to Like)
            ZStack {
                AsyncImage(url: URL(string: post.postImageURL ?? "")) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFit()
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .aspectRatio(1, contentMode: .fit) // Square placeholder
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color.igBackground)
                
                // Big Heart Overlay Animation
                if isHeartOverlayVisible {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                        .shadow(radius: 10)
                        .scaleEffect(isHeartAnimating ? 1.3 : 0.8)
                        .opacity(isHeartAnimating ? 0 : 1)
                }
            }
            .contentShape(Rectangle()) // Ensure the tap area covers the whole ZStack
            .onTapGesture(count: 2) {
                // Optimistic UI for big heart
                if !post.likedByUser {
                    onLikeTapped()
                }
                animateBigHeart()
            }
            
            // MARK: - Actions Row
            HStack(spacing: 16) {
                // Left Actions
                Button(action: {
                    // Trigger haptic
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    
                    onLikeTapped()
                }) {
                    IGIcon(
                        post.likedByUser ? .heartFilled : .heart,
                        color: post.likedByUser ? IGTheme.Colors.likeRed : .igPrimaryText
                    )
                    .scaleEffect(post.likedByUser ? 1.1 : 1.0)
                    .animation(.spring(response: 0.2, dampingFraction: 0.5), value: post.likedByUser)
                }
                
                IGIcon(.comment)
                IGIcon(.share)
                
                Spacer()
                
                // Right Action
                IGIcon(.bookmark)
            }
            .padding(.horizontal, IGTheme.Spacing.m)
            .padding(.vertical, IGTheme.Spacing.s)
            
            // MARK: - Likes Count
            if post.likeCount > 0 {
                Text("\(post.likeCount) likes")
                    .font(IGTypography.button())
                    .foregroundColor(.igPrimaryText)
                    .padding(.horizontal, IGTheme.Spacing.m)
                    .padding(.bottom, IGTheme.Spacing.xxs)
            }
            
            // MARK: - Caption
            HStack(alignment: .top, spacing: 4) {
                Text(post.userName ?? "")
                    .font(IGTypography.captionBold())
                    .foregroundColor(.igPrimaryText) +
                Text(" ") +
                Text(post.postDescription ?? "")
                    .font(IGTypography.caption())
                    .foregroundColor(.igPrimaryText)
            }
            .padding(.horizontal, IGTheme.Spacing.m)
            .padding(.bottom, IGTheme.Spacing.xxs)
            
            // MARK: - Timestamp
            Text("2 hours ago") // Placeholder, or derive from post.updatedAt
                .font(IGTypography.timestamp())
                .foregroundColor(.igSecondaryText)
                .padding(.horizontal, IGTheme.Spacing.m)
                .padding(.bottom, IGTheme.Spacing.m)
        }
    }
    
    private func animateBigHeart() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isHeartOverlayVisible = true
            isHeartAnimating = false
        }
        
        // Scale up and fade out
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.8)) {
                isHeartAnimating = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isHeartOverlayVisible = false
            isHeartAnimating = false
        }
    }
}
