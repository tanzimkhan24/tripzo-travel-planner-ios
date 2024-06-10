//
//  HomeScreenViewController.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 24/4/2024.
//

//"AIzaSyDLpWZCxK62J2vMItzi_yGuyCfMfdFgeeA"

import UIKit
import CoreLocation
import FirebaseFirestoreSwift

class HomeScreenViewController: UIViewController, DatabaseListener, CLLocationManagerDelegate {
    
    
    func onSignIn() {
        //
    }
    
    func onAccountCreated() {
        //
    }
    
    func onError(_ error: any Error) {
        //
    }
    
    func onSignOut() {
        //
    }
    
    func onNewUser(userDetails: Users?) {
        //
    }
    
    weak var databaseController: DatabaseProtocol?
        
    var listenerType = ListenerType.all
    
    
    @IBOutlet weak var yourTripsCollectionView: UICollectionView!
    @IBOutlet weak var tripCategoryCollectionView: UICollectionView!
    @IBOutlet weak var popularTripsCollectionView: UICollectionView!
    
    @IBAction func addTripsPressed(_ sender: Any) {
        performSegue(withIdentifier: "showSuggestedTrips", sender: self)
    }

    let predefinedCategories: [String: [String]] = [
        "Nature": ["park", "campground", "natural_feature"],
        "Leisure": ["tourist_attraction", "museum", "amusement_park"],
        "Shopping": ["shopping_mall", "store", "supermarket"],
        "Dining": ["restaurant", "cafe", "bakery"],
        "Historical": ["church", "museum", "historical"],
        "Entertainment": ["movie_theater", "night_club", "casino"]
    ]

    var categories: [TripCategory] = []
    var popular: [Trip] = [] {
        didSet {
            DispatchQueue.main.async {
                self.popularTripsCollectionView.reloadData()
            }
        }
    }
    var filteredTrips: [Trip] = [] {
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
        loadItineraries()
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        yourTripsCollectionView.addGestureRecognizer(longPressRecognizer)
        
        categories = []
        
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
        guard let databaseController = databaseController else { return }

        for itinerary in itineraries {
            databaseController.addItinerary(itinerary: itinerary) { error in
                if let error = error {
                    print("Error adding itinerary: \(error.localizedDescription)")
                    return
                }
                print("Itinerary saved: \(itinerary)")
            }
        }
    }
    
    func loadItineraries() {
        databaseController?.getItineraries { result in
            switch result {
            case .success(let itineraries):
                self.itineraries = itineraries
                DispatchQueue.main.async {
                    self.yourTripsCollectionView.reloadData()
                }
            case .failure(let error):
                print("Error loading itineraries: \(error.localizedDescription)")
            }
        }
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
                let itineraryToDelete = self.itineraries[indexPath.row]
                self.databaseController?.deleteItinerary(itinerary: itineraryToDelete) { error in
                    if let error = error {
                        print("Error deleting itinerary: \(error.localizedDescription)")
                        self.displayMessage(title: "Error", message: "Could not delete the itinerary. Please try again.")
                        return
                    }
                    
                    self.itineraries.remove(at: indexPath.row)
                    self.yourTripsCollectionView.deleteItems(at: [indexPath])
                    
                    // Reload the collection view to reflect the changes
                    self.yourTripsCollectionView.reloadData()
                }
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewAllTrips", let viewAllTripsVC = segue.destination as? ViewAllTripsViewController {
            viewAllTripsVC.homeScreenViewController = self
        } else if segue.identifier == "showItineraryDetails", let itineraryDetailsVC = segue.destination as? ItineraryDetailsViewController, let selectedItinerary = sender as? Itinerary {
            itineraryDetailsVC.itinerary = selectedItinerary
            itineraryDetailsVC.tripLabelText = "Your trip to \(selectedItinerary.cityName)"
        }
    }
    
    func fetchNearbyCities(location: CLLocation, nextPageToken: String? = nil) {
        let apiKey = "AIzaSyDLpWZCxK62J2vMItzi_yGuyCfMfdFgeeA"
        var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(location.coordinate.latitude),\(location.coordinate.longitude)&radius=5000000&type=tourist_attraction&key=\(apiKey)"
        
        if let token = nextPageToken {
            urlString += "&pagetoken=\(token)"
        }
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
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
                            let tripCategory = self.categorizeTrip(types: place.types)
                            print("Trip: \(place.name), Category: \(String(describing: tripCategory))") // Print statement for debugging
                            let trip = Trip(
                                id: place.place_id,
                                title: place.name,
                                imageUrl: imageUrl ?? "",
                                cityName: place.name,
                                countryName: countryName,
                                types: place.types,
                                category: tripCategory
                            )
                            self.popular.append(trip)
                        case .failure(let error):
                            print("Error fetching country name: \(error)")
                        }
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    self.popularTripsCollectionView.reloadData()
                    self.activityIndicator.stopAnimating()
                    if let nextPageToken = placesResponse.next_page_token {
                        self.fetchNearbyCities(location: location, nextPageToken: nextPageToken)
                    } else {
                        self.fetchCategoriesFromTrips()
                    }
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
        let urlString = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=1600&photoreference=\(photoReference)&key=\(apiKey)"
        
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
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
    
    func categorizeTrip(types: [String]) -> String? {
        for (category, googleTypes) in predefinedCategories {
            if types.contains(where: googleTypes.contains) {
                return category
            }
        }
        return nil
    }
    
    func fetchCategoriesFromTrips() {
        let categoriesSet = Set(popular.compactMap { $0.category })
        
        categories = categoriesSet.map { category in
            let imageName: String
            switch category {
            case "Nature":
                imageName = "Nature"
            case "Leisure":
                imageName = "Leisure"
            case "Shopping":
                imageName = "Shopping"
            case "Dining":
                imageName = "Dining"
            case "Historical":
                imageName = "Historical"
            case "Entertainment":
                imageName = "Entertainment"
            default:
                imageName = "default" // Provide a default image name if necessary
            }
            
            return TripCategory(id: UUID().uuidString, name: category, image: UIImage(named: imageName) ?? UIImage())
        }
        
        DispatchQueue.main.async {
            print("Categories: \(self.categories)")
            self.tripCategoryCollectionView.reloadData()
        }
    }


}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension HomeScreenViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case tripCategoryCollectionView:
            return categories.count
        case popularTripsCollectionView:
            return filteredTrips.isEmpty ? popular.count : filteredTrips.count
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
            let trip = filteredTrips.isEmpty ? popular[indexPath.row] : filteredTrips[indexPath.row]
            cell.setup(trip: trip)
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
            let selectedCategory = categories[indexPath.row].name
            filteredTrips = popular.filter { $0.category == selectedCategory }
            popularTripsCollectionView.reloadData()
        } else if collectionView == yourTripsCollectionView {
            let selectedItinerary = itineraries[indexPath.row]
            performSegue(withIdentifier: "showItineraryDetails", sender: selectedItinerary)
        } else {
            // Handle other selections if needed
        }
    }
}
