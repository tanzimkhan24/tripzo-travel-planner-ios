//
//  HomeScreenViewController.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 24/4/2024.
//

import UIKit

class HomeScreenViewController: UIViewController, DatabaseListener {
    
    
    @IBOutlet weak var tripCategoryCollectionView: UICollectionView!
    
    @IBOutlet weak var popularTripsCollectionView: UICollectionView!
    var categories: [TripCategory] = []
    var popular: [Trip] = []
    
    func onNewUser(userDetails: Users?) {
        //
    }
    
    
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
        
        
        tripCategoryCollectionView.delegate = self
        tripCategoryCollectionView.dataSource = self
        popularTripsCollectionView.delegate = self
        popularTripsCollectionView.dataSource = self
        
        categories = [
            TripCategory(id: "id1", name: "Hiking", image: .screen1),
            TripCategory(id: "id2", name: "Travel", image: .screen2),
            TripCategory(id: "id3", name: "Flight", image: .screen1),
            TripCategory(id: "id1", name: "Hiking", image: .screen2),
            TripCategory(id: "id2", name: "Travel", image: .screen1),
            TripCategory(id: "id3", name: "Flight", image: .screen2)
        ]
        
        popular = [
            Trip(id: "id1", location: "Melbourne", country: "Australia", image: .melbourne),
            Trip(id: "id2", location: "Sydney", country: "Australia", image: .sydney),
            Trip(id: "id3", location: "GoldCoast", country: "Australia", image: .goldCoast),
            Trip(id: "id4", location: "Brisbane", country: "Australia", image: .brisbane),
            Trip(id: "id5", location: "Hobart", country: "Australia", image: .tasmania)
        ]
        
        registerCells()

        // Do any additional setup after loading the view.
    }
    
    func registerCells() {
        tripCategoryCollectionView.register(UINib(nibName: CategoryCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        popularTripsCollectionView.register(UINib(nibName: TripViewCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: TripViewCollectionViewCell.identifier)
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

extension HomeScreenViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView {
        case tripCategoryCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as! CategoryCollectionViewCell
            
            cell.setup(category: categories[indexPath.row])
            
            return cell
        case popularTripsCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TripViewCollectionViewCell.identifier, for: indexPath) as! TripViewCollectionViewCell
            
            cell.setup(trip: popular[indexPath.row])
            
            return cell
        default: return UICollectionViewCell()
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case tripCategoryCollectionView:
            return categories.count
        case popularTripsCollectionView:
            return popular.count
        default: return 0
        }
    }
    
}
