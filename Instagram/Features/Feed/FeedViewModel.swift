import SwiftUI
import Combine

@MainActor
class FeedViewModel: ObservableObject {
    @Published var posts: [PostEntity] = []
    @Published var errorMessage: String?
    @Published var showToast = false
    @Published var isLoading = false
    
    private let repository: FeedRepository
    private let networkMonitor = NetworkMonitor.shared
    
    var isOffline: Bool {
        !networkMonitor.isConnected
    }
    
    init(repository: FeedRepository = FeedRepository()) {
        self.repository = repository
    }
    
    func loadFeed() {
        isLoading = true
        Task {
            do {
                let fetchedPosts = try await repository.getPosts()
                self.posts = fetchedPosts
            } catch {
                // If we have cached posts, it's okay, just show error toast maybe
                if posts.isEmpty {
                    errorMessage = "Failed to load feed: \(error.localizedDescription)"
                    showToast = true
                }
            }
            isLoading = false
        }
    }
    
    func toggleLike(for post: PostEntity) {
        Task {
            do {
                try await repository.toggleLike(post: post)
                // Success: Do NOT re-fetch feed from network.
                // The local object `post` is already updated in Core Data by the repository.
                // Since PostEntity is an ObservableObject (Core Data Class), the UI should reflect the change.
                
                // If we absolutely need to reload from DB (e.g. to re-sort), we should add a specific method
                // that doesn't trigger a network call. But for a like toggle, this is unnecessary overhead.
            } catch {
                errorMessage = "Failed to update like. Please try again."
                showToast = true
                // Revert UI: If the repository failed, it already reverted the DB state.
                // But we might want to ensure the UI catches up if something went wrong.
                // We can just let the ObservableObject update handle it.
            }
        }
    }
}

