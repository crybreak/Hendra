//
//  ForgetPasswordView.swift
//  Hendra
//
//  Created by Wilfried Mac Air on 09/03/2024.
//

import SwiftUI

struct ForgetPasswordView: View {
    
    @EnvironmentObject var authManager: AuthentificationManager
    @EnvironmentObject var userManager: UserManager

    
    @State var isEditing: Bool = false


    @State private var color = Color(hex: "#D12E34")!
    
    var body: some View {
        VStack {
            VStack (alignment: .leading, spacing: 30){
                VStack (alignment: .leading ){
                    Text("Mot de passe oublié")
                        .font(Font.custom("Nunito Sans", size: 28))
                        .bold()
                        .multilineTextAlignment(.leading)
                        .padding(.bottom, 10)
                        .padding([.top], 40)
                    
                    Text("Ne vous inquiétez pas ! Saisissez votre adresse email ci-dessous et nous vous enverrons un code")
                        .foregroundColor(Color(hex: "475569"))
                }
                
               
                VStack (alignment: .leading ){
                    Text("E-mail")
                    TextField("Adress email", text: $authManager.email, onEditingChanged: { isBegin in
                        isEditing = isBegin
                    })
                    .TextFieldModifier(error: userManager.getUserError != nil, isEditing: isEditing)
                    .keyboardType(.emailAddress)
                    if userManager.getUserError != nil {
                        HStack {
                            Image(systemName: "exclamationmark.circle")
                            Text(userManager.getUserError!)
                        } .foregroundColor(color)
                    }
                }
                
            }
            
            Spacer()
            VStack {
                Button {
                    userManager.getUserbyMail.send(authManager.email)
    
                } label: {
                    
                    ZStack {
                        Text("\(!userManager.isLoading ? "Envoyer" : "")")
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .padding(.horizontal, !userManager.isLoading ? UIScreen.main.bounds.width * 0.32 : UIScreen.main.bounds.width * 0.4)
                            .padding()
                            .background{
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: "E15F39")!)
                            }
                        if userManager.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                    }
                }.navigationDestination(isPresented: $userManager.shouldNavigate) {
                    VerificationAccountView(goToForgotPassword: true)
                }
                .disabled(userManager.isLoading)
            }
            Spacer()
                        
        }
        .font(Font.custom("Nunito Sans", size: 14))
        .padding()
        .onAppear {
            userManager.users = []
        }
    }
}

#Preview {
    ForgetPasswordView()
        .environmentObject(AuthentificationManager())
        .environmentObject(UserManager())

}
