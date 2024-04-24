//
//  User.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 25/4/2024.
//

import UIKit
import FirebaseFirestoreSwift

enum Gender: String {
    case male
    case female
    case other
}

class User: NSObject, Codable {
    
    @DocumentID var id: String?
    var name: String
    var phoneNumber: Int
    var country: String
    var gender: String?
    var email: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case phoneNumber
        case country
        case gender
        case email
    }

}

extension User {
    var genderUniverse: Gender {
        get {
            return Gender(rawValue: self.gender!)!
        }
        
        set {
            self.gender = newValue.rawValue
        }
    }
}
