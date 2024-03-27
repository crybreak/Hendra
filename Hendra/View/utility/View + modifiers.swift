//
//  View + modifiers.swift
//  Hendra
//
//  Created by Wilfried Mac Air on 23/02/2024.
//

import SwiftUI


extension View {
    func TextFieldModifier(error: Bool = false, isEditing: Bool = false) -> some View {
        return self
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding(13)
            .overlay(
                   RoundedRectangle(cornerRadius: 8)
                    .stroke(error ? Color(hex: "#D12E34")!
                            : isEditing ? Color.blue : Color.gray.opacity(0.8) , lineWidth: 1)
               )
    }
    
}

final class Utilities {
    static let shared = Utilities()
    private init() {}
    
    @MainActor
    func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        
        let controller = controller ?? UIApplication.shared.keyWindow?.rootViewController
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
