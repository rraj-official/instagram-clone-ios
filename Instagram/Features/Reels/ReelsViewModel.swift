import SwiftUI
import AVKit

class ReelsViewModel: ObservableObject {
    @Published var reels: [ReelEntity] = []
    @Published var errorMessage: String?
    @Published var showToast = false
    @Published var isLoading = false
    
    private let repository: ReelsRepository
    
    init(repository: ReelsRepository = ReelsRepository()) {
        self.repository = repository
    }
    
    func loadReels() {
        isLoading = true
        Task {
            do {
                let fetchedReels = try await repository.getReels()
                await MainActor.run {
                    self.reels = fetchedReels
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    if reels.isEmpty {
                        errorMessage = "Failed to load reels"
                        showToast = true
                    }
                    isLoading = false
                }
            }
        }
    }
    
    func toggleLike(for reel: ReelEntity) {
        Task {
            do {
                try await repository.toggleLike(reel: reel)
                // No re-fetch needed, optimistic update handles UI
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to update like"
                    showToast = true
                }
            }
        }
    }
}


