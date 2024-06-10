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
    
    
    
    func configure(with photo: UnsplashPhoto) {
        
        tripGalleryImage.layer.cornerRadius = 10
        guard let url = URL(string: photo.urls.regular!) else { return }
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    self.tripGalleryImage.image = UIImage(data: data)
                }
            }
        }
    }
}
