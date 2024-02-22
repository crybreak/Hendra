//
//  HendraApp.swift
//  Hendra
//
//  Created by Wilfried Mac Air on 22/02/2024.
//

import SwiftUI

@main
struct HendraApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
