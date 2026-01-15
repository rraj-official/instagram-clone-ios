import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    
    var body: some View {
        // Removed NavigationView since MainTabView (App Shell) should handle structural hierarchy 
        // or this view is just content.
        // If we need navigation for detail screens, we can wrap content, 
        // but for the "Home Tab" look, we usually hide the standard nav bar.
        
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Custom Top Bar
                IGFeedTopBar()
                
                if viewModel.isOffline {
                    Text("No Internet Connection")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.9))
                }
                
                ScrollView {
                    // Stories Row
                    IGStoriesRow()
                    
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.posts, id: \.objectID) { post in
                            PostRowView(post: post) {
                                viewModel.toggleLike(for: post)
                            }
                        }
                    }
                }
                .refreshable {
                    viewModel.loadFeed()
                }
            }
            .background(Color.igBackground)
            
            if viewModel.showToast, let message = viewModel.errorMessage {
                ToastBanner(message: message, isError: true)
                    .padding(.bottom, 50)
                    .transition(.move(edge: .bottom))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                viewModel.showToast = false
                            }
                        }
                    }
            }
        }
        .onAppear {
            viewModel.loadFeed()
        }
    }
}

