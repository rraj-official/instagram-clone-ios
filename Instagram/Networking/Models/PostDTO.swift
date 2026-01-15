import Foundation

struct FeedResponseDTO: Codable {
    let feed: [PostDTO]
}

struct PostDTO: Codable, Identifiable {
    let post_id: String
    let user_name: String
    let user_image: String
    let post_image: String
    let like_count: Int
    let liked_by_user: Bool
    
    var id: String { post_id }
}

struct LikeRequest: Codable {
    let like: Bool
    let post_id: String?
    let reels_id: String?
}
