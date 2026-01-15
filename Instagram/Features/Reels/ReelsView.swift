import SwiftUI
import AVKit

struct ReelPlayerView: View {
    let url: URL
    @State private var player: AVPlayer?
    @Binding var isMuted: Bool
    let isVisible: Bool
    
    var body: some View {
        VideoPlayer(player: player)
            .onAppear {
                setupPlayer()
            }
            .onChange(of: isVisible) { visible in
                if visible {
                    player?.play()
                } else {
                    player?.pause()
                }
            }
            .onChange(of: isMuted) { muted in
                player?.isMuted = muted
            }
            .onDisappear {
                player?.pause()
            }
    }
    
    private func setupPlayer() {
        if player == nil {
            player = AVPlayer(url: url)
            player?.isMuted = isMuted
        }
        if isVisible {
            player?.play()
        }
    }
}

struct SingleReelView: View {
    @ObservedObject var reel: ReelEntity
    @Binding var isMuted: Bool
    let isVisible: Bool
    let onLikeTapped: () -> Void
    
    // UI Interactions
    @State private var isHeartAnimating = false
    @State private var isHeartOverlayVisible = false
    @State private var isPaused = false
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Video Layer
            if let videoURL = reel.reelVideoURL, let url = URL(string: videoURL) {
                ReelPlayerView(url: url, isMuted: $isMuted, isVisible: isVisible && !isPaused)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        isPaused.toggle()
                    }
                    // Double Tap to Like
                    .onTapGesture(count: 2) {
                        if !reel.likedByUser {
                            onLikeTapped()
                        }
                        animateBigHeart()
                    }
            } else {
                Color.black
            }
            
            // Big Heart Overlay
            if isHeartOverlayVisible {
                Image(systemName: "heart.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.white)
                    .shadow(radius: 10)
                    .scaleEffect(isHeartAnimating ? 1.3 : 0.8)
                    .opacity(isHeartAnimating ? 0 : 1)
            }
            
            // Pause Indicator
            if isPaused {
                Image(systemName: "play.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.8))
                    .shadow(radius: 10)
            }
            
            // Overlay UI (Right actions + Bottom info)
            IGReelOverlay(
                reel: reel,
                onLikeTapped: {
                    // Haptic
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    onLikeTapped()
                },
                onCommentTapped: {},
                onShareTapped: {},
                onMoreTapped: {}
            )
        }
    }
    
    private func animateBigHeart() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isHeartOverlayVisible = true
            isHeartAnimating = false
        }
        
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

struct ReelsView: View {
    @StateObject private var viewModel = ReelsViewModel()
    @State private var currentReelIndex = 0
    @State private var isMuted = true
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            GeometryReader { geometry in
                // Vertical paging using TabView with rotation hack
                TabView(selection: $currentReelIndex) {
                    ForEach(Array(viewModel.reels.enumerated()), id: \.element.objectID) { index, reel in
                        SingleReelView(
                            reel: reel,
                            isMuted: $isMuted,
                            isVisible: currentReelIndex == index,
                            onLikeTapped: {
                                viewModel.toggleLike(for: reel)
                            }
                        )
                        .tag(index)
                        .rotationEffect(.degrees(-90))
                        // CRITICAL: Match width to height and height to width of CONTAINER because the parent is rotated 90 degrees.
                        // The frame inside the rotated view must essentially swap dimensions relative to the geometry reader.
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
                .rotationEffect(.degrees(90))
                .frame(width: geometry.size.height, height: geometry.size.width)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2) // Ensure centered
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .ignoresSafeArea()
            }
            .ignoresSafeArea()
            
            // Mute Toggle
            Button(action: { isMuted.toggle() }) {
                Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }
            .padding(.top, 50)
            .padding(.trailing, 20)
        }
        .onAppear {
            viewModel.loadReels()
        }
    }
}

