//
//  InstagramApp.swift
//  Instagram
//
//  Created by Rohit Raj on 21/12/25.
//

import SwiftUI

@main
struct InstagramApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
