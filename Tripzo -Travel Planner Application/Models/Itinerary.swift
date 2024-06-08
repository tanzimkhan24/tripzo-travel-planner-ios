//
//  Itinerary.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 8/6/2024.
//

import Foundation
import UIKit

struct Itinerary: Codable {
    let cityName: String
    let countryName: String
    let attractions: [Attraction]
    var imageData: Data?
    
    var image: UIImage? {
        if let data = imageData {
            return UIImage(data: data)
        }
        return nil
    }
}

