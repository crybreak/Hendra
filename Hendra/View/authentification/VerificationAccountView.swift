//
//  VerificationAccountView.swift
//  Hendra
//
//  Created by Wilfried Mac Air on 28/02/2024.
//

import SwiftUI

struct VerificationAccountView: View {
    @StateObject  var clockModel = ClockModelManager()
    
    @EnvironmentObject var authManager: AuthentificationManager
    @EnvironmentObject var userManager: UserManager

    
    @FocusState var activeField: CodeField?
    
    @State var codeFields: [String] = Array(repeating: "", count: 6)
    @State var color = Color.gray.opacity(0.9)
    @State var message: String = ""
    @State var notification: Bool = false
    @State var codeIsCorrect : Bool = false
    
    @State var goToForgotPassword : Bool = false
    @State var goToHomeView : Bool = false

    

    var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm:ss"
        return dateFormatter
    }
    
    var body: some View {
        VStack {
            
            VStack (alignment: .leading){
               HeaderField()
                Text("Entrer le code").foregroundColor(Color(hex: "1E293B"))
                    .padding(.top)

                CodeField()
                Text(message)
                    .foregroundStyle(Color(hex: "#E15F39")!)
                ZStack {
                    
                    VStack (alignment: .leading, spacing: 5) {
                        HStack {
                            Text("Vous n'avez pas reçu le code ?").foregroundColor(Color(hex: "475569"))
                            Button(action: {
                                clockModel.resendCode = true
                                notification.toggle()
                            }, label: {
                                Text(" Renvoyer le code").foregroundColor(Color(hex: "94A3B8")).bold()  })
                        }
                        
                        Group {
                            Text("Renvoi du code dans ")
                            + Text(dateFormatter.string(from: Date(timeIntervalSinceReferenceDate: TimeInterval(clockModel.second))))
                        }.foregroundColor(Color(hex: "475569"))
                    }.padding([.top, .bottom])
                    
                    if notification {
                        NotificationResetCode()
                            .zIndex(1)
                    }

                }
            }
            ButtonView(timeout: clockModel.timeOut)
                .padding(.top)
        }
        .font(Font.custom("Nunito Sans", size: 14))
      

        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        .onChange(of: codeFields) { newValue in
            codeCondition(value: newValue)
            color = Color.gray.opacity(0.9)
            message = ""
        }
        .onReceive(clockModel.$resendCode.dropFirst(), perform: { _ in
            if goToHomeView == true {
                authManager.resetCode.send()
            } else if goToForgotPassword == true {
                userManager.resetCode.send()
            }
        })
        .onAppear {
            activeField = activeStateForIndex(index: 0)
        }
    }
    
    @ViewBuilder
    
    func NotificationResetCode () -> some View {
        HStack (alignment: .center) {
            Image(systemName: "app.badge.fill")
                .foregroundColor(.red)
            
            Text("Code dans 30 secondes. Vérifiez votre addresse mail ou spam.")
                .foregroundColor(.white)
            
            Button(action: {
                notification = false
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
                notification = false
            }
        }
        .onTapGesture(perform: {
            withAnimation (.easeOut(duration: 2)) {
                notification = false
            }
        })

        
    }
    
    func HeaderField() -> some View {
        VStack (alignment: .leading, spacing: 4) {
            Text("Verification de compte")
                .font(Font.custom("Nunito Sans", size: 28))
                .bold()
                .multilineTextAlignment(.leading)
                .padding(.bottom, 10)
                .padding([.top], 40)

            Group {
                Text("Le code a été envoyé ") + Text(authManager.email).foregroundColor(Color(hex: "1E293B")).bold()
                Text("Entrez le code pour vérifier votre compte.")
            }
            .foregroundColor(Color(hex: "475569"))
        }
    }
    
    func CodeField() -> some View {
        HStack (spacing: 14) {
            ForEach(0..<6, id: \.self) {index in
                VStack (spacing: 14) {
                    TextField("", text: $codeFields[index])
                        .font(Font.custom("Nunito Sans", size: 16))
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        .multilineTextAlignment(.center)
                        .focused($activeField, equals: activeStateForIndex(index: index))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(activeField == activeStateForIndex(index: index) ? .blue :
                                            color,  lineWidth: activeField == nil ? 2 : 1)
                        }
                        .background {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: "D9D9D9")!)
                        }
                   
                }
                .frame(width: 40, height: 40)
                
            }
        }
    }
    
    func ButtonView(timeout: Bool) -> some View {
        VStack {
            Button {
                activeField = nil
                if authManager.code == codeFields.reduce("", { $0 + $1}) {
                    userManager.addNewUser.send(authManager.user!)
                    codeIsCorrect = true
                }  else if userManager.code == codeFields.reduce("", { $0 + $1}) {
                    codeIsCorrect = true
                }else {
                    message = "Code de vérification incorrect"
                    color = Color(hex: "#E15F39")!
                }
            } label: {
                Group {
                    if codeFields.reduce("", { $0 + $1}).count != 6
                        || timeout {
                        Text("Verifiez le code")
                            .foregroundColor(Color(hex: "#D12E34")!)
                            .padding(.horizontal, 100)
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(hex: "#D12E34")!, lineWidth: 1)
                            }
                    } else {
                        ZStack {
                            Text("Vérifiez le code" )
                                .fontWeight(.heavy)
                                .foregroundColor(.white)
                                .padding(.horizontal, 100)
                                .padding()
                                .background{
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(hex: "#E15F39")!)
                                }
                        }
                        
                    }
                }

            }.disabled(codeFields.reduce("", { $0 + $1}).count < 6 || timeout)
                .navigationDestination(isPresented: $codeIsCorrect) {
                    if goToHomeView {
                        HomePageview()
                    } else if goToForgotPassword {
                        PasswordChangView()
                    }
                }

                
        }
    }
    
    func codeCondition(value: [String]) {
        for index in 0..<5 {
            if value[index].count == 1 && activeStateForIndex(index: index) == activeField {
                activeField = activeStateForIndex(index: index +  1)
            }
        }
        
        for index in 1...5 {
            if value[index].isEmpty && !value[index - 1].isEmpty {
                activeField = activeStateForIndex(index: index - 1)
            }
        }
        for index in 0..<6 {
            if value[index].count > 1 {
                codeFields[index] = String(value[index].last!)
            }
        }
    }
   
    func activeStateForIndex(index: Int ) -> CodeField {
        switch index {
        case 0: return .field1
        case 1: return .field2
        case 2: return .field3
        case 3: return .field4
        case 4: return .field5
        case 5: return .field6
        default : return .field7
        }
    }
    
}


struct ContinueLoginButton: View {
    @ObservedObject var authManager: AuthentificationManager
   
    @State var loader : Bool = false
    @State private var color = Color(hex: "#E15F39")!

    var body: some View {
        Button {
            
        } label: {
            
            ZStack {
                Text("Continuer")
                    .foregroundColor(.white)
                    .bold()
                    .padding(.horizontal, 100)
                    .padding()
                    .background{
                        RoundedRectangle(cornerRadius: 8)
                            .fill(color)
                    }
            }

        }
    }
}

enum CodeField {
    case field1
    case field2
    case field3
    case field4
    case field5
    case field6
    case field7



}


#Preview {
    NavigationView {
        VerificationAccountView()
            .environmentObject(AuthentificationManager())
    }
   
}
