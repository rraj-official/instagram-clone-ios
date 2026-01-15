import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: IGTabBar.Tab = .home
    // Access core data context to pass down if needed, though Environment handles it mostly
    @Environment(\.managedObjectContext) var viewContext
    
    // We need to pass the logout capability. 
    // Since `InstagramApp` manages `isLoggedIn`, we can access it via Binding or closure if passed.
    // However, `InstagramApp` structure uses `@AppStorage`.
    // Let's rely on the child views to handle logout or pass a closure.
    // For now, "Profile" tab will just be the Logout button placeholder.
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Content
            ZStack {
                switch selectedTab {
                case .home:
                    FeedView()
                case .search:
                    Text("Search (Placeholder)")
                case .add:
                    Text("Add Post (Placeholder)")
                case .reels:
                    ReelsView()
                case .profile:
                    // Profile / Settings
                    VStack {
                        Text("Profile")
                        Button("Logout") {
                            isLoggedIn = false
                        }
                        .padding()
                        .foregroundColor(.red)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar
            // We only show it if not in full-screen scenarios, but Reels usually has tab bar on top?
            // Actually IG Reels shows Tab Bar.
            IGTabBar(selectedTab: $selectedTab)
        }
        .edgesIgnoringSafeArea(.bottom) // Let TabBar handle bottom spacing
    }
}


