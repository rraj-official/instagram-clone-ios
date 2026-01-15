import Foundation
import CoreData
import Combine

class PendingActionSyncer {
    static let shared = PendingActionSyncer()
    
    private let networkMonitor = NetworkMonitor.shared
    private let api = APIClient.shared
    private let dao = PendingActionsDAO()
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // Observe network changes
        Task { @MainActor in
            networkMonitor.$isConnected
                .receive(on: DispatchQueue.main)
                .sink { [weak self] isConnected in
                    if isConnected {
                        Task {
                            self?.processPendingActions()
                        }
                    }
                }
                .store(in: &cancellables)
        }
    }
    
    func startMonitoring() {
        print("🚀 PendingActionSyncer started")
        // Trigger initial check
        Task { @MainActor in
            if networkMonitor.isConnected {
                processPendingActions()
            }
        }
    }
    
    func processPendingActions() {
        Task {
            do {
                let pendingActions = try dao.fetchPendingActions()
                guard !pendingActions.isEmpty else { return }
                
                print("🔄 Syncing \(pendingActions.count) pending actions...")
                
                for action in pendingActions {
                    guard let targetId = action.targetId, let type = action.targetType else {
                        dao.removeAction(action)
                        continue
                    }
                    
                    let isLiked = action.desiredLikedState
                    let endpoint: APIEndpoints = isLiked ? .like : .dislike
                    
                    // Construct body based on type
                    let body: LikeRequest
                    if type == "post" {
                        body = LikeRequest(like: isLiked, post_id: targetId, reels_id: nil)
                    } else {
                        body = LikeRequest(like: isLiked, post_id: nil, reels_id: targetId)
                    }
                    
                    do {
                        try await api.perform(endpoint, method: isLiked ? "POST" : "DELETE", body: body)
                        print("✅ Synced action for \(type) \(targetId)")
                        dao.removeAction(action)
                    } catch {
                        print("❌ Sync failed for \(targetId): \(error)")
                        // For this simple implementation, we just leave it to retry later.
                        // Ideally increment retry count and delete after N attempts.
                    }
                }
            } catch {
                print("Failed to fetch pending actions: \(error)")
            }
        }
    }
}

