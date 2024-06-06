//
//  AttractionTableViewCell.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 22/5/2024.
//

import UIKit
import SDWebImage

class AttractionTableViewCell: UITableViewCell {

    @IBOutlet weak var attractionImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var cellBackgroundView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    func setupUI() {
        // Round the corners of the image view
        attractionImageView.layer.cornerRadius = 10
        attractionImageView.clipsToBounds = true

        // Customize cell background view
        cellBackgroundView.layer.cornerRadius = 15
        cellBackgroundView.layer.shadowColor = UIColor.black.cgColor
        cellBackgroundView.layer.shadowOpacity = 0.1
        cellBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cellBackgroundView.layer.shadowRadius = 5
        cellBackgroundView.backgroundColor = .systemBackground

        // Set font styles
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        addressLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        addressLabel.textColor = .secondaryLabel


        // Set fixed height for the image view
        attractionImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        attractionImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
    }

    func configure(with attraction: Attraction) {
        nameLabel.text = attraction.title
        addressLabel.text = attraction.cityName

        // Placeholder image
        let placeholderImage = UIImage(named: "placeholder")

        if let imageUrl = attraction.imageUrl {
            attractionImageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: placeholderImage)
        } else {
            attractionImageView.image = placeholderImage
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        UIView.animate(withDuration: 0.3) {
            self.cellBackgroundView.backgroundColor = selected ? UIColor.systemBlue.withAlphaComponent(0.2) : UIColor.systemBackground
        }
    }
    
}
