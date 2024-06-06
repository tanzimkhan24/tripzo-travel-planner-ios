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
    
    func configure(trip: Trip?) {
            if let trip = trip {
                // Display the trip details
                tripImage.image = trip.image // Ensure image names are correctly managed
                tripCity.text = trip.location
                tripCountry.text = trip.country
                tripImage.isHidden = false
            } else {
                // Configure as 'Add Trip'
                tripImage.image = UIImage(systemName: "plus.circle.fill") // Or any appropriate icon
                tripCity.text = "Add New Trip"
                tripCountry.text = ""
                tripImage.isHidden = false
            }
        }
    
}
