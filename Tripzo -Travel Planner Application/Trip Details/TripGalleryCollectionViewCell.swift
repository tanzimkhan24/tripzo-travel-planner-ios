//
//  TripGalleryCollectionViewCell.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 1/5/2024.
//


import UIKit

class TripGalleryCollectionViewCell: UICollectionViewCell {

    static let identifier = "TripGalleryCollectionViewCell"

    
    @IBOutlet weak var tripGalleryImage: UIImageView!
    
    func setup(tripGallery: TripGallery) {
        tripGalleryImage.image = tripGallery.image
    }
}
