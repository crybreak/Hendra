//
//  CreateAccountButton.swift
//  Hendra
//
//  Created by Wilfried Mac Air on 07/03/2024.
//

import SwiftUI


struct CreateAccountButton: View {
    @ObservedObject var authManager: AuthentificationManager
    @State var shouldNavigate = false

   
    @State private var color = Color(hex: "#D12E34")!
    @State var active : Bool = false

    var body: some View {

        Button {
            if authManager.user == nil
                || ( authManager.email != authManager.user!.email ) {
                authManager.createNewUserRequest.send((authManager.email, authManager.password))
            } else {
                if authManager.email ==  authManager.user!.email {
                    authManager.verifyCodeAuth()
                    authManager.shouldNavigate = true
                }
            }
        } label: {
            Group {
                if authManager.disableCreateUserButton {
                    Text("Remplir les champs")
                        .foregroundColor(color)
                        .padding(.horizontal, 90)
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(color, lineWidth: 1)
                        }
                } else {
                    ZStack (alignment: .center) {
                        Text("\(!authManager.isLoading ? "Créer un compte" : "")")
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .padding(.horizontal, !authManager.isLoading ? UIScreen.main.bounds.width * 0.25 : UIScreen.main.bounds.width * 0.4)
                        
                            .padding()
                            .background{
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: "#E15F39")!)
                            }
                        
                        if authManager.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                    }
                }
            }
            
        }
        .disabled(authManager.disableCreateUserButton || authManager.isLoading)
        .navigationDestination(isPresented: $authManager.shouldNavigate) {
            VerificationAccountView(goToHomeView: true)
        }
    }

}
