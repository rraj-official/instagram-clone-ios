//
//  InstagramApp.swift
//  Instagram
//
//  Created by Rohit Raj on 21/12/25.
//

import SwiftUI

@main
struct InstagramApp: App {
    // We are replacing the template PersistenceController with our CoreDataStack
    let coreDataStack = CoreDataStack.shared
    
    // Track login state at the app root level to switch root views
    @AppStorage("isLoggedIn") var isLoggedIn = false
    
    init() {
        // Start the background syncer
        PendingActionSyncer.shared.startMonitoring()
    }

    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                // Use our new MainTabView with custom TabBar
                MainTabView(isLoggedIn: $isLoggedIn)
                    .environment(\.managedObjectContext, coreDataStack.context)
            } else {
                LoginView()
            }
        }
    }
}
