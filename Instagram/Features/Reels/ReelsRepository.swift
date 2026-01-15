import Foundation
import CoreData

class ReelsRepository {
    private let api: APIClientProtocol
    private let dao: ReelsDAO
    private let networkMonitor: NetworkMonitor
    
    init(api: APIClientProtocol = APIClient.shared, 
         dao: ReelsDAO = ReelsDAO(),
         networkMonitor: NetworkMonitor = NetworkMonitor.shared) {
        self.api = api
        self.dao = dao
        self.networkMonitor = networkMonitor
    }
    
    func getReels() async throws -> [ReelEntity] {
        if await networkMonitor.isConnected {
            do {
                let response: ReelResponseDTO = try await api.fetch(.reels, method: "GET", body: nil)
                await dao.saveReels(response.reels)
            } catch {
                print("Reels fetch failed: \(error)")
                // If this is a decoding error, it might be wrapped like the feed was.
                // But let's assume array first or fix if user reports error.
                throw error
            }
        }
        return try dao.fetchReels()
    }
    
    func toggleLike(reel: ReelEntity) async throws {
        let isNowLiked = !reel.likedByUser
        let reelId = reel.reelId ?? ""
        
        // 1. Optimistic Update
        dao.updateLikeState(reelId: reelId, isLiked: isNowLiked)
        
        if await networkMonitor.isConnected {
            do {
                let endpoint: APIEndpoints = isNowLiked ? .like : .dislike
                let body = LikeRequest(like: isNowLiked, post_id: nil, reels_id: reelId)
                try await api.perform(endpoint, method: isNowLiked ? "POST" : "DELETE", body: body)
            } catch {
                // Revert
                dao.updateLikeState(reelId: reelId, isLiked: !isNowLiked)
                throw error
            }
        } else {
            // Queue offline
            let pendingDAO = PendingActionsDAO()
            pendingDAO.enqueueAction(targetId: reelId, type: "reel", isLiked: isNowLiked)
        }
    }
}

