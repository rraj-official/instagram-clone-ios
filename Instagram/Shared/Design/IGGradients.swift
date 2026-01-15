import SwiftUI

struct IGGradients {
    static let storyRing = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 252/255, green: 175/255, blue: 69/255), // Yellow/Orange
            Color(red: 245/255, green: 96/255, blue: 64/255),  // Red/Orange
            Color(red: 225/255, green: 48/255, blue: 108/255), // Pink
            Color(red: 193/255, green: 53/255, blue: 132/255), // Purple
            Color(red: 131/255, green: 58/255, blue: 180/255)  // Deep Purple
        ]),
        startPoint: .bottomLeading,
        endPoint: .topTrailing
    )
    
    static let greyRing = LinearGradient(
        gradient: Gradient(colors: [.gray.opacity(0.3), .gray.opacity(0.3)]),
        startPoint: .top,
        endPoint: .bottom
    )
}


