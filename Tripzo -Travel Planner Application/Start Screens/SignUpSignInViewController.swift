//
//  SignUpSignInViewController.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 11/6/2024.
//

import UIKit

class SignUpSignInViewController: UIViewController, DatabaseListener {

    weak var databaseController: DatabaseProtocol?
    
    var listenerType = ListenerType.all
    
    func onSignIn() {
        self.performSegue(withIdentifier: "success", sender: self)
    }
    
    func onAccountCreated() {
        self.performSegue(withIdentifier: "success", sender: self)
    }
    
    func onError(_ error: any Error) {
        let message = error.localizedDescription
        DispatchQueue.main.async {
                self.displayMessage(title: "Error", message: message)
            }
    }
    
    func onSignOut() {
        //
    }
    
    func onNewUser(userDetails: Users?) {
        //
    }
    
    
    @IBOutlet weak var username: UITextField!
    
    
    @IBOutlet weak var password: UITextField!
    
    
    @IBAction func loginPressed(_ sender: Any) {
        guard let email = username.text, !email.isEmpty, isValidEmail(email) else {
            displayMessage(title: "Error", message: "Missing email")
            return
        }

        guard let password = password.text, !password.isEmpty else {
            displayMessage(title: "Error", message: "Missing password")
            return
        }
        
        databaseController?.signInWithEmail(email: email, password: password)
    }
    
    @IBAction func signUpPressed(_ sender: Any) {
        
        print("Adding user")

            guard let email = username.text, !email.isEmpty, isValidEmail(email) else {
                displayMessage(title: "Error", message: "Missing name")
                return
            }

            guard let password = password.text, !password.isEmpty else {
                displayMessage(title: "Error", message: "Missing country")
                return
            }
        databaseController?.createAccountWithEmail(email: email, password: password) { success, error in
            DispatchQueue.main.async {
                if success {
                    // User was created, now add additional details
                    self.databaseController?.addUser(name: "name", phoneNumber: "0333333", country: "country", gender: "gender", email: email)
                } else if let error = error {
                    self.displayMessage(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        
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
        
       
        
        
        
        
        

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    
    
    func isValidEmail(_ email: String) -> Bool {
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
            return emailTest.evaluate(with: email)
    }
    
    func displayMessage(title: String, message: String) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true, completion: nil)
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
