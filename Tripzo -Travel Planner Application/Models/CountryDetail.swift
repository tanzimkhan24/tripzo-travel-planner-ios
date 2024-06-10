//
//  CountryDetail.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 10/6/2024.
//

struct CountryDetail: Codable {
    let name: String
    let population: Int
    let region: String
    let subregion: String
    let area: Double
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case population = "population"
        case region = "region"
        case subregion = "subregion"
        case area = "area"
        case description = "description"
    }
}

