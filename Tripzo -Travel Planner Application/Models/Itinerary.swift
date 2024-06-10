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
    var attractions: [Attraction]
    var imageUrl: String?
    
    var image: UIImage? {
        if let urlString = imageUrl, let url = URL(string: urlString) {
            do {
                let data = try Data(contentsOf: url)
                return UIImage(data: data)
            } catch {
                print("Error loading image data: \(error)")
                return nil
            }
        }
        return nil
    }
}


