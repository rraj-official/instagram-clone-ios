import SwiftUI

struct IGReelOverlay: View {
    @ObservedObject var reel: ReelEntity
    let onLikeTapped: () -> Void
    let onCommentTapped: () -> Void
    let onShareTapped: () -> Void
    let onMoreTapped: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack(alignment: .bottom) {
                // Bottom Left Info
                VStack(alignment: .leading, spacing: 10) {
                    // User Row
                    HStack {
                        AsyncImage(url: URL(string: reel.userImageURL ?? "")) { phase in
                            if let image = phase.image {
                                image.resizable().scaledToFill()
                            } else {
                                Color.gray
                            }
                        }
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 1))
                        
                        Text(reel.userName ?? "Unknown")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        
                        // Follow button placeholder
                        Text("Follow")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                    }
                    
                    // Description
                    if let description = reel.reelDescription, !description.isEmpty {
                        Text(description)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .lineLimit(2)
                    }
                    
                    // Audio Tag Placeholder
                    HStack(spacing: 6) {
                        Image(systemName: "music.note")
                            .font(.system(size: 12))
                        Text("Original Audio")
                            .font(.system(size: 13))
                            .lineLimit(1)
                    }
                    .foregroundColor(.white)
                }
                .padding(.bottom, 20)
                .padding(.leading, 16)
                
                Spacer()
                
                // Right Side Actions
                VStack(spacing: 24) {
                    // Like
                    VStack(spacing: 6) {
                        Button(action: onLikeTapped) {
                            Image(systemName: reel.likedByUser ? "heart.fill" : "heart")
                                .font(.system(size: 28))
                                .foregroundColor(reel.likedByUser ? .red : .white)
                        }
                        Text("\(reel.likeCount)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    // Comment
                    VStack(spacing: 6) {
                        Button(action: onCommentTapped) {
                            Image(systemName: "bubble.right")
                                .font(.system(size: 26))
                                .foregroundColor(.white)
                        }
                        Text("0")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    // Share
                    Button(action: onShareTapped) {
                        Image(systemName: "paperplane")
                            .font(.system(size: 26))
                            .foregroundColor(.white)
                    }
                    
                    // More
                    Button(action: onMoreTapped) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                    
                    // Music Album Art Placeholder (Spinning box)
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.white, lineWidth: 2)
                        .background(Color.gray.opacity(0.5))
                        .frame(width: 30, height: 30)
                        .cornerRadius(6)
                }
                .padding(.bottom, 40)
                .padding(.trailing, 16)
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.black.opacity(0.6), .clear]),
                startPoint: .bottom,
                endPoint: .center
            )
        )
    }
}


