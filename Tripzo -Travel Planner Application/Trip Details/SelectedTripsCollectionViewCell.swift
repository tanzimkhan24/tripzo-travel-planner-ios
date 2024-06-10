//
//  SelectedTripsCollectionViewCell.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 7/6/2024.
//

import UIKit

class SelectedTripsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var attractionImageView: UIImageView!
    
    @IBOutlet weak var cityName: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var cardView: UIView!
    
    func configure(with city: City) {
        cityName.text = city.name
        addressLabel.text = city.country
        
        attractionImageView.layer.cornerRadius = 20
        
        let placeholderImage = UIImage(named: "placeholder")
        let imageURL = city.imageUrl ?? ""
        attractionImageView.sd_setImage(with: URL(string: imageURL), placeholderImage: placeholderImage)
    }
    
    
    func configure(with attraction: Attraction) {
        cityName.text = attraction.title
        addressLabel.text = attraction.cityName
        
        attractionImageView.layer.cornerRadius = 20
        
        let placeholderImage = UIImage(named: "placeholder")
        let imageURL = attraction.imageUrl ?? ""
        attractionImageView.sd_setImage(with: URL(string: imageURL), placeholderImage: placeholderImage)
    }

}
