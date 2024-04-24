//
//  HomeScreenViewController.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 24/4/2024.
//

import UIKit

class HomeScreenViewController: UIViewController, DatabaseListener  {
    
    weak var databaseController: DatabaseProtocol?
    
    var listenerType = ListenerType.all
    
    func onSignIn() {
        //
    }
    
    func onAccountCreated() {
        //
    }
    
    func onError(_ error: any Error) {
        print("Error")
        let message = error.localizedDescription
        DispatchQueue.main.async {
                self.displayMessage(title: "Logout Error", message: message)
            }
    }
    
    func onSignOut() {
        print("SignOutSuccess")
        DispatchQueue.main.async {
                print("Success")
            self.displayMessage(title: "Success", message: "Successfully signed out!")
            }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController

        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func signOutTapped(_ sender: Any) {
        databaseController?.signOut()
        navigationController?.popViewController(animated: true)
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
