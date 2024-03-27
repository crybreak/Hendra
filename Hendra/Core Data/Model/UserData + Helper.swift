//
//  User + Helper.swift
//  Hendra
//
//  Created by Wilfried Mac Air on 23/02/2024.
//

import Foundation
import CoreData
//MARK: Models

extension UserData {
    var uuid: UUID {
        #if DEBUG
        self.uuid_!
        #else
        self.uuid_ ?? UUID()
        #endif
    }
    
    var name: String {
        get {
            self.name_ ?? ""
        } set (newValue) {
            self.name_ = newValue
        }
    }
    
    var fullName: String {
        get {
            self.fullName_ ?? ""
        } set (newValue) {
            self.fullName_ = newValue
        }
    }
    
    var number: String {
        get {self.number_ ?? ""}
        set (newValue){
            self.number_ = newValue
        }
    }
    
    var email: String {
        get {self.email_ ?? ""}
        set (newValue){
            self.email_ = newValue
        }
    }
    
    convenience init(username: (String, String),  context: NSManagedObjectContext) {
        self.init(context: context)
        self.name = username.0
        self.fullName = username.1
    }
    
    public override func awakeFromInsert() {
        self.creationDate_ = Date() + TimeInterval()
        self.uuid_ = UUID()
    }
    
    
}

//MARK: FETCH REQUEST


extension UserData {
    static func fetch(_ predicate: NSPredicate) -> NSFetchRequest <UserData> {
        let request = NSFetchRequest<UserData>(entityName: "UserData")
        request.predicate = predicate
        return request
    }
}
