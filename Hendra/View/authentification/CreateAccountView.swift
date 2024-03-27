//
//  CreateAccountView.swift
//  Hendra
//
//  Created by Wilfried Mac Air on 23/02/2024.
//

import SwiftUI

struct CreateAccountView: View {
    @EnvironmentObject var authManager: AuthentificationManager

    var body: some View {
        ScrollView (showsIndicators: false) {
            VStack (alignment: .leading, spacing: 20) {
                Spacer()
                
                Text("Créer un compte")
                    .font(Font.custom("Nunito Sans", size: 30))
                    .bold()
                Spacer()
                
                UserNameTextField(authManager: authManager)
                
                EmailTextField(authManager: authManager)
                
                PasswordTextField(authManager: authManager, checkFeedbackId: 0)
                
                PasswordTextField(authManager: authManager , checkFeedbackId: 1)

            }
            .padding()
            CreateAccountButton(authManager: authManager)
            
            PolicyTextView(authManager: authManager)
        }

        .font(Font.custom("Nunito Sans", size: 14))
        
        .onAppear {
            authManager.email = ""
            authManager.password = ""
            authManager.feedBackEmail = ""
        }
    }
}

struct UserNameTextField: View {
    @ObservedObject var authManager: AuthentificationManager

    @State private var isEditingName = false
    @State private var isEditingFullName = false
    @State private var username: (String, String) = ("","")

    
    var body: some View {
        HStack {
            VStack (alignment: .leading) {
                Text("Nom")
                TextField("John", text: $username.0 , onEditingChanged: { isBegin in
                    isEditingName = isBegin
                })
                .TextFieldModifier(isEditing: isEditingName )
            }
            VStack ( alignment: .leading) {
                Text("Prénoms")
                TextField("Doe", text: $username.1, onEditingChanged: { isBegin in
                    isEditingFullName = isBegin
                })
                .TextFieldModifier(isEditing: isEditingFullName)
            }
        }
    }
}

struct EmailTextField: View {
    @ObservedObject var authManager: AuthentificationManager

    @State var isEditing: Bool = false

    @State private var color = Color(hex: "#D12E34")!
    var body: some View {
        VStack (alignment: .leading)  {
            Text("E-mail")
            TextField("Adress email", text: $authManager.email, onEditingChanged: { isBegin in
                isEditing = isBegin
            })
            .TextFieldModifier(error: !authManager.feedBackEmail.isEmpty, isEditing: isEditing)
            .keyboardType(.emailAddress)
            if !authManager.feedBackEmail.isEmpty {
                HStack {
                    Image(systemName: "exclamationmark.circle")
                    Text(authManager.feedBackEmail)
                } .foregroundColor(color)
            }
        }
    }
}

struct PasswordTextField: View {
    @ObservedObject var authManager: AuthentificationManager

    var checkFeedbackId: Int
    
    @State var isEditing: Bool = false
    @State private var color = Color(hex: "#D12E34")!

    var body: some View {
        VStack ( alignment: .leading)  {
            Text(checkFeedbackId == 0 ? "Mot de passe" : "Confirmation mot de passe")
            TextField("********", text: checkFeedbackId == 0 ? $authManager.password : $authManager.passwordConfirm,
                      onEditingChanged: { isBegin in
                isEditing = isBegin
            })
            .keyboardType(.alphabet)
            .TextFieldModifier(error: authManager.feedBackText.0 == checkFeedbackId,  isEditing: isEditing)
            
            if  authManager.feedBackText.0 == checkFeedbackId {
                HStack {
                    Image(systemName: "exclamationmark.circle")
                    Text(authManager.feedBackText.1)
                }
                .foregroundColor(color)
            } else if  authManager.feedBackText.0 == 2 {
                Text(authManager.feedBackText.1)
                    .foregroundStyle(Color.black.opacity(0.6))
            }
        }
    }
}

struct PolicyTextView: View {
    @ObservedObject var authManager: AuthentificationManager

    @State private var appear: Bool = false
    @State private var color = Color(hex: "#E15F39")!


    
    var body: some View {
        ZStack (alignment: .leading){
            Group {
                Text("En continuant, vous acceptez nos")
                    .foregroundColor(Color(hex: "#475569"))

                +
                Text(" Conditions de service ")
                    .foregroundColor(color)
                    .bold()
                
                + Text("et notre ")
                    .foregroundColor(Color(hex: "#475569"))

                + Text("Politique de Confidentialité.")
                    .foregroundColor(color)
                    .bold()

            }
            .font(Font.custom("Nunito Sans", size: 14))

            .padding()
            .zIndex(0)
            
            if authManager.noConnection == true {
               NoConnexionView(authManager: authManager)
                .zIndex(1)
               
            }
            
        }
    }
}




struct NoConnexionView: View {
    @ObservedObject var authManager: AuthentificationManager

    var body: some View {
        
        HStack {
            Image(systemName: "wifi.exclamationmark")
                .foregroundColor(.red)
            
            Text("Problème de connexion internet")
                .foregroundColor(.white)
            
            Button(action: {
                authManager.noConnection = false
            }, label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(Color.gray)
                    .padding(.leading)
            })
            
        }
        .padding()
        .font(Font.custom("Nunito Sans", size: 14))


        .background {
            Color(hex: "093855")
        }
        .onAppear {
            withAnimation (.easeOut.delay(2)) {
                authManager.noConnection = false
            }
        }
        .onTapGesture(perform: {
            withAnimation (.easeOut(duration: 2)) {
                authManager.noConnection = false
            }
        })

    }
}


#Preview {
        CreateAccountView()
        .environmentObject(AuthentificationManager())
}


