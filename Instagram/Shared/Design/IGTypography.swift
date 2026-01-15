import SwiftUI

struct IGTypography {
    // Helper to return Font with specific weight
    static func username() -> Font {
        .system(size: 14, weight: .semibold)
    }
    
    static func caption() -> Font {
        .system(size: 14, weight: .regular)
    }
    
    static func captionBold() -> Font {
        .system(size: 14, weight: .semibold) // For username in caption
    }
    
    static func timestamp() -> Font {
        .system(size: 12, weight: .regular)
    }
    
    static func storyLabel() -> Font {
        .system(size: 11, weight: .regular)
    }
    
    static func headerTitle() -> Font {
        // "Instagram" script font replacement or just heavy system font
        // IG uses a custom image logo, we will use a distinct font style
        .system(size: 24, weight: .bold, design: .default) // Placeholder for wordmark
    }
    
    static func button() -> Font {
        .system(size: 14, weight: .semibold)
    }
}


