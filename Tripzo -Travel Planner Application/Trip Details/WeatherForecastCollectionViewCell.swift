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
    
    @IBOutlet weak var cardView: UIView!
    
    required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }

    override init(frame: CGRect) {
            super.init(frame: frame)
    }
    
    override func awakeFromNib() {
            super.awakeFromNib()
            setupCardView()
    }

    
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
        }
    
    func setupCardView() {
            cardView.layer.cornerRadius = 10
            cardView.layer.shadowColor = UIColor.black.cgColor
            cardView.layer.shadowOpacity = 0.1
            cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
            cardView.layer.shadowRadius = 4
            cardView.layer.masksToBounds = false
        cardView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        }

}
