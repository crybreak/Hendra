//
//  PasswordChangView.swift
//  Hendra
//
//  Created by Wilfried Mac Air on 10/03/2024.
//

import SwiftUI

struct PasswordChangView: View {
    
    @EnvironmentObject var authManager: AuthentificationManager

    var body: some View {
        VStack {
            VStack  (alignment: .leading, spacing: 20) {
                Text("Nouveau mot de passe")
                    .font(Font.custom("Nunito Sans", size: 28))
                    .bold()
                    .multilineTextAlignment(.leading)
                    .padding([.top], 40)
                
                Text("Veuillez saisir et confirmer votre nouveau mot de passe. Vous devrez vous connecter après la réinitialisation")
                    .foregroundColor(Color(hex: "475569"))
                
                
                PasswordTextField(authManager: authManager, checkFeedbackId: 0)
                
                PasswordTextField(authManager: authManager , checkFeedbackId: 1)
            }
            
            Spacer()
            VStack {
                Button {
                
                } label: {
                    
                    ZStack {
                        Text("\(!authManager.isLoading ? "Réinitialiser le mot de passe" : "")")
                            .foregroundColor(.white)
                            .fontWeight(.heavy)
                            .padding(.horizontal, !authManager.isLoading ? UIScreen.main.bounds.width * 0.12   : UIScreen.main.bounds.width * 0.4)
                            .padding()
                            .background{
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: "E15F39")!)
                            }
                        if authManager.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                    }
                }.navigationDestination(isPresented: $authManager.shouldNavigate) {
                    VerificationAccountView(goToForgotPassword: true)
                }
            }
            Spacer()
        }
            .navigationBarHidden(true)
            .font(Font.custom("Nunito Sans", size: 14))
            .padding()

    }
}

#Preview {
    PasswordChangView()
        .environmentObject(AuthentificationManager())
}
