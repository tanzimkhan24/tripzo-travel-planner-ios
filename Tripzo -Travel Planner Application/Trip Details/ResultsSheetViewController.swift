//
//  ResultsSheetViewController.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 10/6/2024.
//

import UIKit
import CoreLocation
import GooglePlaces
import FloatingPanel

struct GooglePlacesSearchResult: Codable {
    let results: [GooglePlace]
}

struct GeoNamesSearchResult: Codable {
    let geonames: [GeoNameDetail]
}

struct GeoNameDetail: Codable {
    let population: Int
    let summary: String?
    let countryCode: String?
}

struct WikipediaSummary: Codable {
    let extract: String
}

class ResultsSheetViewController: UIViewController, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var countryDetailsLabel: UILabel!
    @IBOutlet weak var populationLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var aboutTextView: UITextView!
    
    var placesClient: GMSPlacesClient!
    var searchResults: [GMSAutocompletePrediction] = []
    var imageCache = NSCache<NSString, UIImage>()
    var placePhotos: [UnsplashPhoto] = []
    weak var placesViewController: PlacesViewController?
    
    var tableView: UITableView!
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        aboutTextView.layer.cornerRadius = 10
        collectionView.layer.cornerRadius = 10
        placesClient = GMSPlacesClient.shared()
        setupUI()
        setupActivityIndicator()
    }
    
    func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func hideUIElements() {
        countryNameLabel.isHidden = true
        countryDetailsLabel.isHidden = true
        populationLabel.isHidden = true
        distanceLabel.isHidden = true
        aboutTextView.isHidden = true
        collectionView.isHidden = true
    }
    
    func showUIElements() {
        countryNameLabel.isHidden = false
        countryDetailsLabel.isHidden = false
        populationLabel.isHidden = false
        distanceLabel.isHidden = false
        aboutTextView.isHidden = false
        collectionView.isHidden = false
    }
    
    func setupUI() {
        hideUIElements()
        searchBar.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        setupTableView()
        setupDividers()
        collectionView.register(UINib(nibName: "TripGalleryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TripGalleryCollectionViewCell")
    }
    
    func setupDividers() {
        let divider1 = UIView()
        divider1.backgroundColor = .lightGray
        divider1.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(divider1)
        
        NSLayoutConstraint.activate([
            divider1.topAnchor.constraint(equalTo: populationLabel.bottomAnchor, constant: 8),
            divider1.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            divider1.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            divider1.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        let divider2 = UIView()
        divider2.backgroundColor = .lightGray
        divider2.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(divider2)
        
        NSLayoutConstraint.activate([
            divider2.topAnchor.constraint(equalTo: distanceLabel.bottomAnchor, constant: 8),
            divider2.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            divider2.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            divider2.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    func setupTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SearchResultCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.isHidden = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            searchResults.removeAll()
            tableView.isHidden = true
            return
        }
        fetchAutocompleteSuggestions(for: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        fetchAutocompleteSuggestions(for: searchText)
    }
    
    func fetchAutocompleteSuggestions(for query: String) {
        let filter = GMSAutocompleteFilter()
        filter.types = ["(regions)"]
        
        placesClient.findAutocompletePredictions(fromQuery: query, filter: filter, sessionToken: nil) { (results, error) in
            if let error = error {
                print("Error fetching autocomplete suggestions: \(error.localizedDescription)")
                return
            }
            
            if let results = results {
                self.searchResults = results
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.tableView.isHidden = false
                }
            }
        }
    }
    
    func fetchPlaceDetails(for placeID: String) {
        let fields: GMSPlaceField = [.name, .coordinate, .addressComponents, .photos]
        placesClient.fetchPlace(fromPlaceID: placeID, placeFields: fields, sessionToken: nil) { (place, error) in
            if let error = error {
                print("Error fetching place details: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                DispatchQueue.main.async {
                    self.hideUIElements()
                    self.activityIndicator.startAnimating()
                    self.countryNameLabel.text = "\(place.name ?? "")"
                    self.countryDetailsLabel.text = "\(place.name ?? "")"
                    self.fetchCountryDetails(for: place.name ?? "")
                    self.placesViewController?.annotateCountry(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude, name: place.name ?? "")
                }
            }
        }
    }
    
    func fetchCountryDetails(for country: String, retryCount: Int = 3) {
        fetchPopulation(for: country, retryCount: retryCount) {
            self.fetchSummary(for: country, retryCount: retryCount) {
                self.fetchImages(for: country) {
                    self.activityIndicator.stopAnimating()
                    self.showUIElements()
                    self.placesViewController?.showPolyline()
                }
            }
        }
    }
    
    func fetchPopulation(for country: String, retryCount: Int = 3, completion: @escaping () -> Void) {
        let username = "tkha0014" // Replace with your GeoNames username
        let urlString = "https://secure.geonames.org/searchJSON?q=\(country)&featureClass=A&maxRows=1&username=\(username)&type=json"
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Failed to fetch country details: \(error.localizedDescription)")
                if retryCount > 0 {
                    print("Retrying... (\(retryCount) attempts left)")
                    self.fetchPopulation(for: country, retryCount: retryCount - 1, completion: completion)
                }
                return
            }
            
            guard let data = data else {
                print("No data received.")
                if retryCount > 0 {
                    print("Retrying... (\(retryCount) attempts left)")
                    self.fetchPopulation(for: country, retryCount: retryCount - 1, completion: completion)
                }
                return
            }
            
            do {
                let response = try JSONDecoder().decode(GeoNamesSearchResult.self, from: data)
                if let countryDetail = response.geonames.first {
                    DispatchQueue.main.async {
                        let formatter = NumberFormatter()
                        formatter.numberStyle = .decimal
                        if let formattedPopulation = formatter.string(from: NSNumber(value: countryDetail.population)) {
                            self.populationLabel.text = "\(formattedPopulation)"
                        } else {
                            self.populationLabel.text = " \(countryDetail.population)"
                        }
                        self.countryDetailsLabel.text! += ", \(countryDetail.countryCode ?? "N/A")"
                        completion()
                    }
                }
            } catch {
                print("Failed to decode country details response: \(error)")
                if retryCount > 0 {
                    print("Retrying... (\(retryCount) attempts left)")
                    self.fetchPopulation(for: country, retryCount: retryCount - 1, completion: completion)
                }
            }
        }.resume()
    }
    
    func fetchImages(for query: String, completion: @escaping () -> Void) {
        let urlString = "https://api.unsplash.com/search/photos?page=1&query=\(query)&client_id=UY7coixlm6n8n7ktFzmSYkt89mUlNp6BUEmDK0s6Dlk"
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to fetch images: \(error?.localizedDescription ?? "Unknown error")")
                completion()
                return
            }
            
            do {
                let response = try JSONDecoder().decode(UnsplashSearchResult.self, from: data)
                self.placePhotos = response.results
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    completion()
                }
            } catch {
                print("Failed to decode images response: \(error)")
                completion()
            }
        }.resume()
    }
    
    func fetchSummary(for country: String, retryCount: Int = 3, completion: @escaping () -> Void) {
        let urlString = "https://en.wikipedia.org/api/rest_v1/page/summary/\(country)"
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Failed to fetch country summary: \(error.localizedDescription)")
                if retryCount > 0 {
                    print("Retrying... (\(retryCount) attempts left)")
                    self.fetchSummary(for: country, retryCount: retryCount - 1, completion: completion)
                }
                return
            }
            
            guard let data = data else {
                print("No data received.")
                if retryCount > 0 {
                    print("Retrying... (\(retryCount) attempts left)")
                    self.fetchSummary(for: country, retryCount: retryCount - 1, completion: completion)
                }
                return
            }
            
            do {
                let response = try JSONDecoder().decode(WikipediaSummary.self, from: data)
                DispatchQueue.main.async {
                    self.aboutTextView.text = response.extract
                    completion()
                }
            } catch {
                print("Failed to decode country summary response: \(error)")
                if retryCount > 0 {
                    print("Retrying... (\(retryCount) attempts left)")
                    self.fetchSummary(for: country, retryCount: retryCount - 1, completion: completion)
                }
            }
        }.resume()
    }
    
    @IBAction func seePlacesToExploreTapped(_ sender: Any) {
        guard let countryName = countryNameLabel.text else { return }
        fetchCities(for: countryName) { cities in
            DispatchQueue.main.async {
                guard let citiesVC = self.storyboard?.instantiateViewController(withIdentifier: "CitiesViewController") as? CitiesViewController else {
                    print("Failed to instantiate CitiesViewController from storyboard.")
                    return
                }
                citiesVC.cities = cities
                citiesVC.placesViewController = self.placesViewController
                let floatingPanel = FloatingPanelController()
                floatingPanel.set(contentViewController: citiesVC)
                self.dismiss(animated: true) {
                    floatingPanel.addPanel(toParent: self.placesViewController!)
                    floatingPanel.move(to: .half, animated: true)
                }
            }
        }
    }

    
    func fetchCities(for country: String, completion: @escaping ([City]) -> Void) {
        let urlString = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=cities+in+\(country)&key=AIzaSyDLpWZCxK62J2vMItzi_yGuyCfMfdFgeeA"
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to fetch cities: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }
            
            do {
                let response = try JSONDecoder().decode(GooglePlacesSearchResult.self, from: data)
                var cities: [City] = []
                let group = DispatchGroup()
                
                for result in response.results {
                    group.enter()
                    
                    self.fetchPhotoURL(for: result.photos?.first?.photo_reference ?? "", apiKey: "AIzaSyDLpWZCxK62J2vMItzi_yGuyCfMfdFgeeA") { photoResult in
                        switch photoResult {
                        case .success(let url):
                            let city = City(
                                name: result.name,
                                country: country,
                                imageUrl: url,
                                latitude: result.geometry.location.lat,
                                longitude: result.geometry.location.lng
                            )
                            cities.append(city)
                        case .failure(let error):
                            print("Error fetching photo URL: \(error)")
                        }
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    completion(cities)
                }
                
            } catch {
                print("Failed to decode cities response: \(error)")
                completion([])
            }
        }.resume()
    }
    
    func fetchPhotoURL(for photoReference: String, apiKey: String, completion: @escaping (Result<String, Error>) -> Void) {
        let urlString = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photoReference)&key=\(apiKey)"
        
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        completion(.success(urlString))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath)
        let result = searchResults[indexPath.row]
        cell.textLabel?.text = result.attributedFullText.string
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = searchResults[indexPath.row]
        fetchPlaceDetails(for: result.placeID)
        tableView.isHidden = true
        self.hideUIElements()
    }
    
    func showSearchResults() {
        // Update your UI with the search results (autocomplete suggestions)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return placePhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TripGalleryCollectionViewCell", for: indexPath) as? TripGalleryCollectionViewCell else {
            return UICollectionViewCell()
        }
        let photo = placePhotos[indexPath.row]
        cell.configure(with: photo)
        return cell
    }
}
