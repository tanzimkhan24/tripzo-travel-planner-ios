//
//  ImageOverlayTableViewCell.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 7/5/2024.
//

import UIKit

class ImageOverlayTableViewCell: UITableViewCell {
    
    let nameLabel = UILabel()
    let cityImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        cityImageView.contentMode = .scaleAspectFill
        cityImageView.clipsToBounds = true
        contentView.addSubview(cityImageView)

        nameLabel.textColor = .white
        nameLabel.font = UIFont.boldSystemFont(ofSize: 18) // Larger font size
        nameLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6) // More opaque background
        nameLabel.textAlignment = .center
        contentView.addSubview(nameLabel)
    }
    
    private func setupConstraints() {
        cityImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cityImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cityImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            cityImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cityImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            nameLabel.heightAnchor.constraint(equalToConstant: 50), // Slightly taller label for better legibility
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with place: Place) {
        nameLabel.text = "\(place.name), \(place.country)"
        cityImageView.image = place.image  // This will be nil initially and set later
    }
}
