//
//  SignUpScreenViewController.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 24/4/2024.
//

import UIKit

class SignUpScreenViewController: UIViewController, DatabaseListener {
    
    func onNewUser(userDetails: Users?) {
        //
    }
    
    
    var listenerType = ListenerType.all
    
    func onSignOut() {
        //
    }
    
    func onSignIn() {
        
    }

    func isUserDataComplete(_ user: Users?) -> Bool {
        guard let user = user else { return false }
        // Validate if the necessary data is present
        return user.name != nil && user.country != nil
    }
    
    func onAccountCreated() {
        self.performSegue(withIdentifier: "regularSignUp", sender: self)
    }
    
    func onError(_ error: Error) {
        let message = error.localizedDescription
        DispatchQueue.main.async {
                self.displayMessage(title: "Sign Up Error", message: message)
            }
    }
    
    weak var databaseController: DatabaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        
        
        DispatchQueue.main.async {
                if self.databaseController?.isUserSignedIn() == true {
                    self.performSegue(withIdentifier: "success", sender: self)
                }
            }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    @IBAction func signWithGoogle(_ sender: Any) {
        
        databaseController?.signInWithGoogle(presentingViewController: self) 
        
    }
    
    
    
    @IBAction func signInWithFacebook(_ sender: Any) {
        databaseController?.signInWithFacebook(from: self)
    }
    
    @IBAction func signInRegularly(_ sender: Any) {
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
