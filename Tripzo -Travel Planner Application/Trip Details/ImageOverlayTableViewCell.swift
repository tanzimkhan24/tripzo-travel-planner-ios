//
//  ImageOverlayTableViewCell.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 7/5/2024.
//

import UIKit

class ImageOverlayTableViewCell: UITableViewCell {
    let cityImageView = UIImageView()
    let titleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    func setupUI() {
        contentView.addSubview(cityImageView)
        contentView.addSubview(titleLabel)
        
        cityImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cityImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cityImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cityImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cityImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        cityImageView.contentMode = .scaleAspectFill
        cityImageView.clipsToBounds = true
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
    }

    func configure(with place: Place) {
        titleLabel.text = place.name
        if let image = place.image {
            cityImageView.image = image
        } else {
            cityImageView.image = nil
        }
    }
}
