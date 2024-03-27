//
//  HomePageview.swift
//  Hendra
//
//  Created by Wilfried Mac Air on 08/03/2024.
//

import SwiftUI

struct HomePageview: View {
    @EnvironmentObject var authManager: AuthentificationManager

    var body: some View {
        VStack {
            Text("Main View")
            
            Text("You are logged in \(authManager.user?.email ?? "none")")
            
            Button(action: {
                authManager.signOutRequest.send()
            },label: {
                Text("Signout")
            })
        }
        .navigationBarHidden(true)


    }
}

#Preview {
    HomePageview()
        .environmentObject( AuthentificationManager())
}
