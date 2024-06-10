//
//  WeatherModel.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 8/5/2024.
//

import Foundation

struct WeatherForecast: Codable {
    let daily: [DailyWeather]
}

struct DailyWeather: Codable {
    let dt: Int
    let sunrise: Int
    let sunset: Int
    let temp: Temperature
    let weather: [WeatherDetail]
    let humidity: Int
    
    var date: Date? {
            return Date(timeIntervalSince1970: Double(dt))
        }
}

struct Temperature: Codable {
    let day: Double
    let min: Double
    let max: Double
    let night: Double
    let eve: Double
    let morn: Double
}

struct WeatherDetail: Codable {
    let main: String
    let description: String
    let icon: String
}
