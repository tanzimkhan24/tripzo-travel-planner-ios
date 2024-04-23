//
//  SemiCircleView.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 22/4/2024.
//

import UIKit

class SemiCircleView: UIView {
    
    let curveHeight: CGFloat = 70.0

        override func draw(_ rect: CGRect) {
            super.draw(rect)
            
            let path = UIBezierPath()
            
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY),
                              controlPoint: CGPoint(x: rect.midX, y: rect.minY + curveHeight))
            
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            
            path.close()
            
            UIColor.white.setFill()
            path.fill()
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            self.backgroundColor = .clear
        }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
