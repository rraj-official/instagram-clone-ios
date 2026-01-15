import SwiftUI

struct IGTheme {
    struct Colors {
        // Adaptive colors for light/dark mode
        static let background = Color("IGBackground")
        static let primaryText = Color("IGPrimaryText")
        static let secondaryText = Color("IGSecondaryText")
        static let separator = Color("IGSeparator")
        static let likeRed = Color(red: 237/255, green: 73/255, blue: 86/255)
        static let linkBlue = Color(red: 0/255, green: 55/255, blue: 107/255)
        
        // Fixed colors
        static let white = Color.white
        static let black = Color.black
    }
    
    struct Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let s: CGFloat = 12
        static let m: CGFloat = 16
        static let l: CGFloat = 24
        static let xl: CGFloat = 32
    }
    
    struct Layout {
        static let avatarSizeSmall: CGFloat = 32
        static let avatarSizeMedium: CGFloat = 40
        static let storyRingSize: CGFloat = 72
        static let storyAvatarSize: CGFloat = 64
        static let iconSize: CGFloat = 24
    }
}

// Extension to use system colors as fallback until assets are added, 
// or define them programmatically here to avoid Asset Catalog dependency for now.
extension Color {
    static let igBackground = Color(UIColor.systemBackground)
    static let igPrimaryText = Color(UIColor.label)
    static let igSecondaryText = Color(UIColor.secondaryLabel)
    static let igSeparator = Color(UIColor.separator)
}


