//
//  LoginPage.swift
//  Hendra
//
//  Created by Wilfried Mac Air on 26/02/2024.
//

import SwiftUI
import GoogleSignInSwift
import AuthenticationServices


struct LoginPageView: View {
    @EnvironmentObject var authManager: AuthentificationManager
    @EnvironmentObject var userManager: UserManager

    @State private var color = Color(hex: "#E15F39")!
    
    
    @State var loader : Bool = false
    @State var createAccountPage : Bool = false
    @State var forgotPassword : Bool = false


    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                
                VStack {
                    VStack ( alignment: .leading, spacing: 20 ){
                        
                        Spacer()
                        Text("Se connecter")
                            .font(Font.custom("Nunito Sans", size: 30))
                            .bold()
                        Spacer()
                        
                        
                        EmailTextField(authManager: authManager)
                        
                        PasswordTextField(authManager: authManager, checkFeedbackId: 0)
                        ZStack (alignment: .leading) {
                            HStack {
                                Button (action: {
                                    forgotPassword.toggle()
                                }, label: {
                                    Text("Mot de passe oublié ?")
                                        .foregroundColor(color)
                                        .bold()
                                })
                                .navigationDestination(isPresented: $forgotPassword) {
                                    ForgetPasswordView()
                                }
                                
                                Spacer()
                                Button {
                                    createAccountPage.toggle()
                                } label: {
                                    Text("Créer un compte?")
                                        .foregroundColor(color)
                                        .bold()
                                }
                                .navigationDestination(isPresented: $createAccountPage) {
                                    CreateAccountView()
                                }
                                
                            }
                            
                            
                            if authManager.noConnection == true {
                               NoConnexionView(authManager: authManager)
                                .zIndex(1)
                               
                            }
                        }
                    }
                    .font(Font.custom("Nunito Sans", size: 14))
                    
                }.padding()
                
                Spacer()
                
                VStack (alignment: .center, spacing: 20) {
                    
                    LoginAccountButton(authManager: authManager)
                    
                    Spacer()
                    Text("ou Se connecte avec")
                        .foregroundColor(Color(hex: "#475569"))
                    AppleSignButton(authManager: authManager)
                    
                    GoogleSignButton(authManager: authManager)

                }
            }
            
        }
        .font(Font.custom("Nunito Sans", size: 16))
        .onAppear {
            authManager.email = ""
            authManager.password = ""
            authManager.feedBackEmail = ""
        }

    }
}


struct GoogleSignButton : View {
    @ObservedObject var authManager: AuthentificationManager

    var body: some View {
        Button   {
            Task {
                do {
                    try await authManager.signInGoogle()

                } catch {
                    print(error.localizedDescription)
                }
            }
        } label: {
            HStack {
                Image("Group 181")
                Text("Se connecter avec Google")
                    .foregroundColor(Color(hex: "#111828"))
            }
        }
        .padding(.horizontal, 38)
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black.opacity(0.8) , lineWidth: 1)
        )
    }
}

struct AppleSignButton : View {
    @ObservedObject var authManager: AuthentificationManager

    var body: some View {
        Button   {
            Task {
               try await authManager.signInApple()
            }
        } label: {
            HStack {
                Image("Apple")
                Text("Se connecter avec Apple")
                    .foregroundColor(Color(hex: "#111828"))
            }
        }
        .padding(.horizontal, 38)
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black.opacity(0.8) , lineWidth: 1)
        )
    }
}


#Preview {
    LoginPageView()
        .environmentObject(AuthentificationManager())
        .environmentObject(UserManager())
}
