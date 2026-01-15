import SwiftUI

struct IGTabBar: View {
    @Binding var selectedTab: Tab
    
    enum Tab: Int {
        case home = 0
        case search = 1
        case add = 2
        case reels = 3
        case profile = 4
    }
    
    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(imageName: "house", filledImageName: "house.fill", isSelected: selectedTab == .home) {
                selectedTab = .home
            }
            
            TabBarButton(imageName: "magnifyingglass", filledImageName: "magnifyingglass", isSelected: selectedTab == .search) {
                selectedTab = .search
            }
            
            TabBarButton(imageName: "plus.app", filledImageName: "plus.app.fill", isSelected: selectedTab == .add) {
                selectedTab = .add
            }
            
            TabBarButton(imageName: "play.rectangle", filledImageName: "play.rectangle.fill", isSelected: selectedTab == .reels) {
                selectedTab = .reels
            }
            
            TabBarButton(imageName: "person.circle", filledImageName: "person.circle.fill", isSelected: selectedTab == .profile) {
                selectedTab = .profile
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
        .padding(.bottom, 20) // Adjust for safe area
        .background(Color.igBackground)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.igSeparator),
            alignment: .top
        )
    }
}

struct TabBarButton: View {
    let imageName: String
    let filledImageName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Spacer()
            Image(systemName: isSelected ? filledImageName : imageName)
                .font(.system(size: 24))
                .foregroundColor(.igPrimaryText)
            Spacer()
        }
    }
}


