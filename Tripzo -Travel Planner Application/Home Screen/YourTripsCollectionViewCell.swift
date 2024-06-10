//
//  YourTripsCollectionViewCell.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 8/5/2024.
//

import UIKit

class YourTripsCollectionViewCell: UICollectionViewCell {

    static let identifier = "YourTripsCollectionViewCell"
    
    @IBOutlet weak var tripImage: UIImageView!
    
    @IBOutlet weak var tripCity: UILabel!
    
    @IBOutlet weak var tripCountry: UILabel!
    
    func setup(itinerary: Itinerary) {
        tripCity.text = itinerary.cityName
        tripCountry.text = itinerary.countryName
        
        tripImage.layer.cornerRadius = 5
        
        if let imageUrl = itinerary.imageUrl, let url = URL(string: imageUrl) {
            tripImage.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
        } else {
            tripImage.image = UIImage(named: "placeholder")
        }
    }
    
}
