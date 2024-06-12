//
//  Trip.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 1/5/2024.
//

import Foundation
import UIKit

struct Trip: Codable {
    let id: String
    let title: String
    let imageUrl: String
    let cityName: String
    let countryName: String
    let types: [String]
    var category: String? 
    let latitude: Double
    let longitude: Double
}


