//
//  UIViewController+Extension.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 1/5/2024.
//

import UIKit

extension UIViewController {
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static func instantiate() -> Self {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: identifier) as! Self
        return controller
    }
}
