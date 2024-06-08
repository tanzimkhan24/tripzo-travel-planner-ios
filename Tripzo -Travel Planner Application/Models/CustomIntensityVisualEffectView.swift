//
//  CustomIntensityVisualEffectView.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 7/6/2024.
//

import UIKit

class CustomIntensityVisualEffectView: UIVisualEffectView {
    var customBlurEffect: UIBlurEffect?
    var intensity: CGFloat

    init(effect: UIVisualEffect?, intensity: CGFloat) {
        self.intensity = intensity
        super.init(effect: effect)
        self.customBlurEffect = effect as? UIBlurEffect
        self.setup()
    }

    required init?(coder: NSCoder) {
        self.intensity = 0.5
        super.init(coder: coder)
        self.customBlurEffect = self.effect as? UIBlurEffect
        self.setup()
    }

    func setup() {
        guard let customBlurEffect = customBlurEffect else { return }
        
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setValue(intensity * 10, forKey: kCIInputRadiusKey)
        
        self.effect = customBlurEffect
    }
}

