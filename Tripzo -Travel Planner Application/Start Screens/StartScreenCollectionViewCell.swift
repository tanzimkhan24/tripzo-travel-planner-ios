//
//  StartScreenCollectionViewCell.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 24/4/2024.
//

import UIKit

class StartScreenCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var startTitle: UILabel!
    
    
    @IBOutlet weak var startDescription: UILabel!
    
    func setup(_ slide: StartScreenSlide) {
        
        startTitle.text = slide.title
        startDescription.text = slide.description
    }
}
