//
//  HomeScreenViewController.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 24/4/2024.
//

//"AIzaSyDLpWZCxK62J2vMItzi_yGuyCfMfdFgeeA"

import UIKit
import CoreLocation

class HomeScreenViewController: UIViewController, DatabaseListener, CLLocationManagerDelegate {
    
    @IBOutlet weak var yourTripsCollectionView: UICollectionView!
    @IBOutlet weak var tripCategoryCollectionView: UICollectionView!
    @IBOutlet weak var popularTripsCollectionView: UICollectionView!
    
    @IBAction func addTripsPressed(_ sender: Any) {
        performSegue(withIdentifier: "showSuggestedTrips", sender: self)
    }
    
    var categories: [TripCategory] = []
    var popular: [Trip] = [] {
        didSet {
            DispatchQueue.main.async {
                self.popularTripsCollectionView.reloadData()
            }
        }
    }
    var itineraries: [Itinerary] = [] {
        didSet {
            DispatchQueue.main.async {
                self.yourTripsCollectionView.reloadData()
            }
        }
    }
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
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
        print("Error: \(error.localizedDescription)")
        let message = error.localizedDescription
        DispatchQueue.main.async {
            self.displayMessage(title: "Error", message: message)
        }
    }
    
    func onSignOut() {
        print("SignOutSuccess")
        DispatchQueue.main.async {
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
        yourTripsCollectionView.delegate = self
        yourTripsCollectionView.dataSource = self
        
        registerCells()
        itineraries = loadItineraries()
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        yourTripsCollectionView.addGestureRecognizer(longPressRecognizer)
        
        categories = [
            TripCategory(id: "id1", name: "Hiking", image: .screen1),
            TripCategory(id: "id2", name: "Travel", image: .screen2),
            TripCategory(id: "id3", name: "Flight", image: .screen1),
            TripCategory(id: "id1", name: "Hiking", image: .screen2),
            TripCategory(id: "id2", name: "Travel", image: .screen1),
            TripCategory(id: "id3", name: "Flight", image: .screen2)
        ]
        
        setupActivityIndicator()
        fetchUserLocation()
    }
    
    func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func fetchUserLocation() {
        activityIndicator.startAnimating()
        LocationManager.shared.getUserLocation { [weak self] location in
            DispatchQueue.main.async {
                guard let strongSelf = self else {
                    return
                }
                print("User location: \(location.coordinate)")
                strongSelf.fetchNearbyCities(location: location)
            }
        }
    }
    
    func registerCells() {
        tripCategoryCollectionView.register(UINib(nibName: CategoryCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        popularTripsCollectionView.register(UINib(nibName: TripViewCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: TripViewCollectionViewCell.identifier)
        yourTripsCollectionView.register(UINib(nibName: YourTripsCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: YourTripsCollectionViewCell.identifier)
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        databaseController?.signOut()
        navigationController?.popViewController(animated: true)
    }
    
    func saveItineraries(_ itineraries: [Itinerary]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(itineraries) {
            UserDefaults.standard.set(encoded, forKey: "itineraries")
        }
        print("Itineraries saved: \(itineraries)")
    }
    
    func loadItineraries() -> [Itinerary] {
        if let savedItineraries = UserDefaults.standard.object(forKey: "itineraries") as? Data {
            let decoder = JSONDecoder()
            if let loadedItineraries = try? decoder.decode([Itinerary].self, from: savedItineraries) {
                print("Itineraries loaded: \(loadedItineraries)")
                return loadedItineraries
            }
        }
        return []
    }
    
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state != .began {
            return
        }

        let point = gesture.location(in: yourTripsCollectionView)
        if let indexPath = yourTripsCollectionView.indexPathForItem(at: point) {
            let alert = UIAlertController(title: "Delete Trip", message: "Are you sure you want to delete this trip?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                // Update the data source
                self.itineraries.remove(at: indexPath.row)
                self.saveItineraries(self.itineraries)
                
                // Reload the collection view to reflect the changes
                self.yourTripsCollectionView.reloadData()
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewAllTrips", let viewAllTripsVC = segue.destination as? ViewAllTripsViewController {
            viewAllTripsVC.homeScreenViewController = self
        } /*else if segue.identifier == "showSuggestedTrips", let suggestedTripsVC = segue.destination as? SuggestedTripsViewController {
            // Pass any necessary data to SuggestedTripsViewController here
        }
           */
    }
    
    func fetchNearbyCities(location: CLLocation) {
        let apiKey = "AIzaSyDLpWZCxK62J2vMItzi_yGuyCfMfdFgeeA"
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(location.coordinate.latitude),\(location.coordinate.longitude)&radius=500000&type=tourist_attraction&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching nearby cities: \(error)")
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
                return
            }
            
            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
                return
            }
            
            do {
                let placesResponse = try JSONDecoder().decode(GooglePlacesResponse.self, from: data)
                let group = DispatchGroup()
                
                for place in placesResponse.results {
                    group.enter()
                    var imageUrl: String? = nil
                    if let photoReference = place.photos?.first?.photo_reference {
                        self.fetchPhotoURL(for: photoReference, apiKey: apiKey) { result in
                            switch result {
                            case .success(let url):
                                imageUrl = url
                            case .failure(let error):
                                print("Error fetching photo URL: \(error)")
                            }
                            group.leave()
                        }
                    } else {
                        group.leave()
                    }
                    
                    group.enter()
                    self.fetchCountryName(for: place.geometry.location) { countryResult in
                        switch countryResult {
                        case .success(let countryName):
                            let trip = Trip(
                                id: place.place_id,
                                title: place.name,
                                imageUrl: imageUrl ?? "",
                                cityName: place.name,
                                countryName: countryName
                            )
                            self.popular.append(trip)
                            print("Trip added: \(trip)")
                        case .failure(let error):
                            print("Error fetching country name: \(error)")
                        }
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    self.popularTripsCollectionView.reloadData()
                    self.activityIndicator.stopAnimating()
                    print("Popular trips loaded: \(self.popular)")
                }
            } catch {
                print("Error decoding response: \(error)")
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
            }
        }
        task.resume()
    }

    func fetchPhotoURL(for photoReference: String, apiKey: String, completion: @escaping (Result<String, Error>) -> Void) {
        let urlString = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photoReference)&key=\(apiKey)"
        
        guard URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") != nil else {
            completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        completion(.success(urlString))
    }

    func fetchCountryName(for location: Location, completion: @escaping (Result<String, Error>) -> Void) {
        let apiKey = "AIzaSyDLpWZCxK62J2vMItzi_yGuyCfMfdFgeeA"
        let urlString = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(location.lat),\(location.lng)&key=\(apiKey)"
        
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let geocodeResponse = try JSONDecoder().decode(GeocodeResponse.self, from: data)
                if let country = geocodeResponse.results.first?.address_components.first(where: { $0.types.contains("country") })?.long_name {
                    completion(.success(country))
                } else {
                    completion(.failure(NSError(domain: "NoCountryFound", code: 2, userInfo: [NSLocalizedDescriptionKey: "No country found"])))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

extension HomeScreenViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case tripCategoryCollectionView:
            return categories.count
        case popularTripsCollectionView:
            return popular.count
        case yourTripsCollectionView:
            return itineraries.count
        default:
            return 0
        }
    }
    
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
        case yourTripsCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: YourTripsCollectionViewCell.identifier, for: indexPath) as! YourTripsCollectionViewCell
            cell.setup(itinerary: itineraries[indexPath.row])
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == tripCategoryCollectionView {
            // Handle category selection
        } else if collectionView == yourTripsCollectionView {
            // Handle trip selection
        } else {
            // Handle popular trip selection
        }
    }
}
