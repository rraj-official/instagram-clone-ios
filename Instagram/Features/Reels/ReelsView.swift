import SwiftUI
import AVKit

// MARK: - Aspect-fill AVPlayer for Instagram-like zoomed video
private struct AspectFillPlayerView: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: Context) -> PlayerContainerView {
        let view = PlayerContainerView()
        view.playerLayer.player = player
        view.playerLayer.videoGravity = .resizeAspect
        view.clipsToBounds = true
        return view
    }
    
    func updateUIView(_ uiView: PlayerContainerView, context: Context) {
        uiView.playerLayer.player = player
    }
    
    final class PlayerContainerView: UIView {
        override static var layerClass: AnyClass { AVPlayerLayer.self }
        var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    }
}

// MARK: - Single Reel Page
private struct ReelPageView: View {
    @ObservedObject var reel: ReelEntity
    @Binding var isMuted: Bool
    let isVisible: Bool
    let onLikeTapped: () -> Void
    
    @State private var player = AVPlayer()
    @State private var isPaused = false
    @State private var isHeartAnimating = false
    @State private var isHeartOverlayVisible = false
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            videoLayer
            if isHeartOverlayVisible { heartOverlay }
            if isPaused { pauseIndicator }
            overlayUI
        }
        .contentShape(Rectangle())
        .background(Color.black)
        .gesture(doubleTapLikeGesture)
        .simultaneousGesture(singleTapPauseGesture)
        .onAppear(perform: configurePlayerIfNeeded)
        .onChange(of: isVisible) { newValue in
            newValue && !isPaused ? player.play() : player.pause()
        }
        .onChange(of: isMuted) { muted in
            player.isMuted = muted
        }
        .onDisappear {
            player.pause()
        }
    }
    
    private var videoLayer: some View {
        Group {
            if let urlString = reel.reelVideoURL, let url = URL(string: urlString) {
                AspectFillPlayerView(player: player)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .ignoresSafeArea()
            } else {
                Color.black
            }
        }
    }
    
    private var overlayUI: some View {
        IGReelOverlay(
            reel: reel,
            onLikeTapped: {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                onLikeTapped()
            },
            onCommentTapped: {},
            onShareTapped: {},
            onMoreTapped: {}
        )
    }
    
    private var pauseIndicator: some View {
        Image(systemName: "play.fill")
            .font(.system(size: 60))
            .foregroundColor(.white.opacity(0.85))
            .shadow(radius: 10)
    }
    
    private var heartOverlay: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: 110))
            .foregroundColor(.white)
            .shadow(radius: 10)
            .scaleEffect(isHeartAnimating ? 1.25 : 0.8)
            .opacity(isHeartAnimating ? 0 : 1)
    }
    
    private var singleTapPauseGesture: some Gesture {
        TapGesture(count: 1).onEnded {
            isPaused.toggle()
            if isPaused {
                player.pause()
            } else if isVisible {
                player.play()
            }
        }
    }
    
    private var doubleTapLikeGesture: some Gesture {
        TapGesture(count: 2).onEnded {
            if !reel.likedByUser {
                onLikeTapped()
            }
            animateBigHeart()
        }
    }
    
    private func configurePlayerIfNeeded() {
        guard player.currentItem == nil,
              let urlString = reel.reelVideoURL,
              let url = URL(string: urlString) else { return }
        
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        player.isMuted = isMuted
        if isVisible {
            player.play()
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

// MARK: - Reels Screen
struct ReelsView: View {
    @StateObject private var viewModel = ReelsViewModel()
    @State private var currentReelIndex = 0
    @State private var isMuted = true
    @State private var scrollPosition: Int? = 0
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollViewReader { _ in
                ScrollView(.vertical) {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(viewModel.reels.enumerated()), id: \.offset) { index, reel in
                            ReelPageView(
                                reel: reel,
                                isMuted: $isMuted,
                                isVisible: currentReelIndex == index,
                                onLikeTapped: {
                                    viewModel.toggleLike(for: reel)
                                }
                            )
                            .frame(maxWidth: .infinity)
                            .containerRelativeFrame(.vertical)
                            .background(Color.black)
                            .id(index)
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .scrollTargetLayout()
                .scrollTargetBehavior(.paging)
                .scrollPosition(id: $scrollPosition)
                .ignoresSafeArea()
            }
            
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
            scrollPosition = 0
        }
        .onChange(of: scrollPosition) { newValue in
            currentReelIndex = newValue ?? 0
        }
        .background(Color.black)
    }
}

