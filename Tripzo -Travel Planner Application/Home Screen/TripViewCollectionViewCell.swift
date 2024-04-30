//
//  TripViewCollectionViewCell.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 1/5/2024.
//

import UIKit

class TripViewCollectionViewCell: UICollectionViewCell {

    static let identifier = "TripViewCollectionViewCell"
    @IBOutlet weak var destinationImageView: UIImageView!
    
    @IBOutlet weak var locationDetails: UILabel!
    
    @IBOutlet weak var countryDetails: UILabel!
    
    func setup(trip: Trip) {
        locationDetails.text = trip.location
        countryDetails.text = trip.country
        destinationImageView.layer.cornerRadius = 5
        destinationImageView.image = trip.image
        
    }

}
