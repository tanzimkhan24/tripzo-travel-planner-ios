//
//  WeatherForecastCollectionViewCell.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 8/5/2024.
//

import UIKit
import SDWebImage


class WeatherForecastCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var weatherIconImageView: UIImageView!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    
    @IBOutlet weak var date: UILabel!

    
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    
    @IBOutlet weak var humidityLabel: UILabel!
    
    
    func configure(with weather: DailyWeather) {
            let tempCelsius = Int(weather.temp.day - 273.15)  // Convert Kelvin to Celsius
            temperatureLabel.text = "\(tempCelsius)°C"
            temperatureLabel.font = UIFont.systemFont(ofSize: 20)
            temperatureLabel.textColor = UIColor.darkText
        

            if let icon = weather.weather.first?.icon {
                let iconURL = "https://openweathermap.org/img/wn/\(icon).png"
                weatherIconImageView.contentMode = .scaleAspectFit
                weatherIconImageView.sd_setImage(with: URL(string: iconURL), placeholderImage: UIImage(named: "placeholder"))
            }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d"
        guard let weatherDate = weather.date else {return}
        let formattedDate = dateFormatter.string(from: weatherDate)
        date.text = formattedDate
        
        if let weatherDescription = weather.weather.first?.description {
            weatherDescriptionLabel.text = weatherDescription.capitalized
        }
        
        humidityLabel.text = "Humidity: \(weather.humidity)%"
        
        }
    
    
    
}
