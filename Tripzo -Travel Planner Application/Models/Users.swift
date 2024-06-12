//
//  User.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 25/4/2024.
//

import UIKit
import FirebaseFirestoreSwift


class Users: NSObject, Codable {
    
    @DocumentID var id: String?
    var name: String?
    var phoneNumber: String?
    var country: String?
    var gender: String?
    var email: String?
    var itineraries: [Itinerary]?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case phoneNumber
        case country
        case gender
        case email
        case itineraries
    }
    
    
}
