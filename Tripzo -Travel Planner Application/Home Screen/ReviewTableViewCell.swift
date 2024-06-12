//
//  ReviewTableViewCell.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 12/6/2024.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {


    @IBOutlet weak var authorLabel: UILabel!
    
    
    @IBOutlet weak var ratingLabel: UILabel!
    
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func configure(with review: Review) {
        self.layer.cornerRadius = 20
        authorLabel.text = "Author: \(review.author_name)"
        ratingLabel.text = "Rating: \(review.rating)"
        descriptionLabel.text = "Review: \(review.text)"
    }
    
}
