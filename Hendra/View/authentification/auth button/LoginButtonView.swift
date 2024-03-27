//
//  LoginButtonView.swift
//  Hendra
//
//  Created by Wilfried Mac Air on 07/03/2024.
//

import SwiftUI

struct LoginAccountButton: View {
    @ObservedObject var authManager: AuthentificationManager
   
    @State var loader : Bool = false
    @State private var color = Color(hex: "#E15F39")!

    var body: some View {
        Button {
            authManager.signInRequest.send((authManager.email, authManager.password))

        } label: {
            
            ZStack {
                Text("\(!authManager.isLoading ? "Se connecter" : "")")
                    .foregroundColor(.white)
                    .fontWeight(.heavy)
                    .padding(.horizontal, !authManager.isLoading ? UIScreen.main.bounds.width * 0.25 : UIScreen.main.bounds.width * 0.4)
                    .padding()
                    .background{
                        RoundedRectangle(cornerRadius: 8)
                            .fill(color)
                    }
                if authManager.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }

        }.disabled(authManager.isLoading)
    }
}
