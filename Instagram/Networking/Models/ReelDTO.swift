import Foundation

struct ReelResponseDTO: Codable {
    let reels: [ReelDTO]
}

struct ReelDTO: Codable, Identifiable {
    let reel_id: String
    let user_name: String
    let user_image: String
    let reel_video: String
    let like_count: Int
    let liked_by_user: Bool
    
    var id: String { reel_id }
}
