import Foundation
import CoreData
import Combine

class FeedRepository {
    private let api: APIClientProtocol
    private let dao: FeedDAO
    private let networkMonitor: NetworkMonitor
    
    init(api: APIClientProtocol = APIClient.shared, 
         dao: FeedDAO = FeedDAO(),
         networkMonitor: NetworkMonitor = NetworkMonitor.shared) {
        self.api = api
        self.dao = dao
        self.networkMonitor = networkMonitor
    }
    
    func getPosts() async throws -> [PostEntity] {
        if await networkMonitor.isConnected {
            // Online: Fetch -> Save -> Load from DB
            do {
                let response: FeedResponseDTO = try await api.fetch(.feed, method: "GET", body: nil)
                await dao.savePosts(response.feed)
            } catch {
                // If API fails, fall back to DB but rethrow if empty?
                // For now, we just swallow error and show cache if available, 
                // or let ViewModel handle the error presentation.
                print("Feed fetch failed: \(error)")
                throw error
            }
        }
        // Always return source of truth from DB
        return try dao.fetchPosts()
    }
    
    func toggleLike(post: PostEntity) async throws {
        let isNowLiked = !post.likedByUser
        let postId = post.postId ?? ""
        
        // 1. Optimistic Update (Local DB)
        dao.updateLikeState(postId: postId, isLiked: isNowLiked)
        
        if await networkMonitor.isConnected {
            // 2. Online: Call API
            do {
                let endpoint: APIEndpoints = isNowLiked ? .like : .dislike
                let body = LikeRequest(like: isNowLiked, post_id: postId, reels_id: nil)
                try await api.perform(endpoint, method: isNowLiked ? "POST" : "DELETE", body: body)
            } catch {
                // 3. Failure: Revert Local DB
                dao.updateLikeState(postId: postId, isLiked: !isNowLiked)
                throw error
            }
        } else {
            // 4. Offline: Enqueue Pending Action
            let pendingDAO = PendingActionsDAO()
            pendingDAO.enqueueAction(targetId: postId, type: "post", isLiked: isNowLiked)
        }
    }
}

