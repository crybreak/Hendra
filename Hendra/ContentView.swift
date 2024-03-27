//
//  ContentView.swift
//  Hendra
//
//  Created by Wilfried Mac Air on 22/02/2024.
//

import SwiftUI
import CoreData

struct ContentView: View {
        
    @StateObject var authManager = AuthentificationManager()
    @StateObject var userManager = UserManager()


    
    var body: some View {
       LoginPageView()
            .environmentObject(authManager)
            .environmentObject(userManager)
    }
}

#Preview(body: {
    ContentView()
        .environmentObject( AuthentificationManager())
        .environmentObject(UserManager())

})
