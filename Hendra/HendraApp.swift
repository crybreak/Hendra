//
//  HendraApp.swift
//  Hendra
//
//  Created by Wilfried Mac Air on 22/02/2024.
//

import SwiftUI
import Firebase

@main
struct HendraApp: App {
    let persistenceController = PersistenceController.shared

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("➡️ AppDelegate - applicationDidFinishLaunching")

        FirebaseApp.configure()
        return true
    }
    
}
