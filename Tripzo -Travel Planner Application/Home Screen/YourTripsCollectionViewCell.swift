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
        
        if let firstAttraction = itinerary.attractions.first, let imageUrl = firstAttraction.imageUrl, let url = URL(string: imageUrl) {
            tripImage.sd_setImage(with: url, completed: nil)
        } else {
            tripImage.image = UIImage(systemName: "photo")
        }
    }
    
}
