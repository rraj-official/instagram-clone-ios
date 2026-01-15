import Foundation

enum APIEndpoints {
    static let baseURL = URL(string: "https://dfbf9976-22e3-4bb2-ae02-286dfd0d7c42.mock.pstmn.io")!
    
    case feed
    case like
    case dislike
    case reels
    
    var url: URL {
        switch self {
        case .feed:
            return APIEndpoints.baseURL.appendingPathComponent("/user/feed")
        case .like:
            return APIEndpoints.baseURL.appendingPathComponent("/user/like") // Changed from /user/dislike to /user/like
        case .dislike:
            return APIEndpoints.baseURL.appendingPathComponent("/user/dislike")
        case .reels:
            return APIEndpoints.baseURL.appendingPathComponent("/user/reels")
        }
    }
}
