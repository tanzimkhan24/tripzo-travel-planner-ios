//
//  TestScreenViewController.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 26/4/2024.
//

import UIKit

class TestScreenViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    
   
    @IBOutlet weak var googleButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let buttonImage = UIImage(named: "google-white.png")
        
        let customColor = UIColor.white
        username.layer.borderColor = customColor.cgColor
        password.layer.borderColor = customColor.cgColor
        
        username.layer.borderWidth = 1.0
        password.layer.borderWidth = 1.0
        
        username.layer.cornerRadius = 10
        password.layer.cornerRadius = 10
        
        username.attributedPlaceholder = NSAttributedString(
            string: "Your Email",
            attributes: [NSAttributedString.Key.foregroundColor: customColor]
            )
        
        password.attributedPlaceholder = NSAttributedString(
            string: "Your Password",
            attributes: [NSAttributedString.Key.foregroundColor: customColor]
            )
        
        googleButton.setBackgroundImage(buttonImage, for: .normal)
        googleButton.setTitle("", for: .normal)
        googleButton.imageView?.contentMode = .scaleAspectFit
        
        
        
        
        

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func googleSignIn(_ sender: Any) {
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
