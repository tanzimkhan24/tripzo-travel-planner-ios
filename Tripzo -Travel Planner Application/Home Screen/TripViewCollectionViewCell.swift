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
        locationDetails.text = trip.cityName
        countryDetails.text = trip.countryName
        destinationImageView.layer.cornerRadius = 5
        
        if let imageUrl = URL(string: trip.imageUrl) {
            destinationImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder"), options: .highPriority, completed: nil)
        } else {
            destinationImageView.image = UIImage(named: "placeholder")
        }
    }
}

