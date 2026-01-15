import SwiftUI

struct IGIcon: View {
    enum IconName: String {
        case home = "house"
        case homeFilled = "house.fill"
        case search = "magnifyingglass"
        case reels = "play.rectangle" // SF Symbol approximation
        case reelsFilled = "play.rectangle.fill"
        case shop = "bag"
        case profile = "person.circle"
        case heart = "heart"
        case heartFilled = "heart.fill"
        case comment = "bubble.right" // or bubble.right (SF Symbol)
        case share = "paperplane"
        case bookmark = "bookmark"
        case bookmarkFilled = "bookmark.fill"
        case more = "ellipsis"
        case add = "plus.app"
        case messenger = "message" // "bolt.horizontal.circle" or similar
    }
    
    let name: IconName
    let size: CGFloat
    let color: Color
    
    init(_ name: IconName, size: CGFloat = 24, color: Color = .primary) {
        self.name = name
        self.size = size
        self.color = color
    }
    
    var body: some View {
        Image(systemName: name.rawValue)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundColor(color)
    }
}


