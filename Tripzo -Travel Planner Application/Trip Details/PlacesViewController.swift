//
//  PlacesViewController.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 1/5/2024.
//

import UIKit

class PlacesViewController: UIViewController {

    var places: [Place] = []
    let placesTableView = UITableView()
    var indicator = UIActivityIndicatorView()
    var imageCache = NSCache<NSString, UIImage>()
    let searchController = UISearchController(searchResultsController: nil)
   
    
    struct UnsplashSearchResult: Codable {
        let results: [UnsplashPhoto]
    }

    struct UnsplashPhoto: Codable {
        let urls: UnsplashPhotoURLs
    }

    struct UnsplashPhotoURLs: Codable {
        let regular: String?
        
        enum CodingKeys: String, CodingKey {
            case regular
        }
    }

    struct SearchResult: Codable {
        let geonames: [GeoName]
    }

    struct GeoName: Codable {
        let name: String
        let countryName: String
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureConstraints()
        placesTableView.register(ImageOverlayTableViewCell.self, forCellReuseIdentifier: "ImageOverlayCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func setupUI() {
        view.addSubview(placesTableView)
        view.addSubview(indicator)
        
        
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Country"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
        definesPresentationContext = true

        placesTableView.delegate = self
        placesTableView.dataSource = self

        indicator.style = UIActivityIndicatorView.Style.large
    }

    func configureConstraints() {
        placesTableView.translatesAutoresizingMaskIntoConstraints = false
        indicator.translatesAutoresizingMaskIntoConstraints = false


        NSLayoutConstraint.activate([
            
        placesTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        placesTableView.leftAnchor.constraint(equalTo: view.leftAnchor),
        placesTableView.rightAnchor.constraint(equalTo: view.rightAnchor),
        placesTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            indicator.centerXAnchor.constraint(equalTo:
                    view.safeAreaLayoutGuide.centerXAnchor),
                    indicator.centerYAnchor.constraint(equalTo:
                    view.safeAreaLayoutGuide.centerYAnchor)

        ])
    }
    
    
    
    func fetchImageForCity(city: String, completion: @escaping (UIImage?) -> Void) {
        let cacheKey = NSString(string: city)
        
        // Check for cached image
        if let cachedImage = imageCache.object(forKey: cacheKey) {
            completion(cachedImage)
            return
        }
        
        // Append "cityscape" to the search query to refine results to city images
        let query = "\(city)"
        let urlString = "https://api.unsplash.com/search/photos?page=1&query=\(query)&client_id=tUYcIS_OsEvaS-PteJ5yToLNvmRXnDLUNaTZfKO5R9A"
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            completion(nil)
            return
        }

        // Create and start a data task to fetch the image
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }

            do {
                let jsonResult = try JSONDecoder().decode(UnsplashSearchResult.self, from: data)
                if let urlString = jsonResult.results.first?.urls.regular, let imageUrl = URL(string: urlString) {
                    // Download the image data
                    let imageDataTask = URLSession.shared.dataTask(with: imageUrl) { imageData, _, imageError in
                        guard let imageData = imageData, imageError == nil else {
                            completion(nil)
                            return
                        }
                        // Create image and cache it
                        if let image = UIImage(data: imageData) {
                            self.imageCache.setObject(image, forKey: cacheKey)
                            completion(image)
                        } else {
                            completion(nil)
                        }
                    }
                    imageDataTask.resume()
                } else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }
        task.resume()
    }

    
    func fetchImagesForPlaces() {
            for (index, place) in places.enumerated() {
                fetchImageForCity(city: place.name) { image in
                    DispatchQueue.main.async {
                        if let image = image {
                            self.places[index].image = image
                            let indexPath = IndexPath(row: index, section: 0)
                            if self.placesTableView.indexPathsForVisibleRows?.contains(indexPath) == true {
                                self.placesTableView.reloadRows(at: [indexPath], with: .fade)
                            }
                        }
                    }
                }
            }
        }

    func searchPlaces(named city: String) async {
            let urlString = "https://secure.geonames.org/searchJSON?q=\(city)&featureClass=P&maxRows=10&username=tkha0014&type=json"
            guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
                DispatchQueue.main.async {
                    self.indicator.stopAnimating()
                }
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                let decoder = JSONDecoder()
                let result = try decoder.decode(SearchResult.self, from: data)
                let newPlaces = result.geonames.map { Place(name: $0.name, country: $0.countryName, image: nil) }
                
                DispatchQueue.main.async {
                    self.places = newPlaces
                    self.placesTableView.reloadData()
                    self.indicator.stopAnimating()
                    self.fetchImagesForPlaces()
                }
            } catch {
                DispatchQueue.main.async {
                    print("Failed to fetch places: \(error)")
                    self.indicator.stopAnimating()
                }
            }
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsSegue",
           let destinationVC = segue.destination as? SelectedTripViewController,
           let selectedIndexPath = placesTableView.indexPathForSelectedRow {
            let selectedPlace = places[selectedIndexPath.row]

            // Ensure that the image is loaded before the segue is performed
            guard let image = selectedPlace.image else {
                print("Image not yet loaded.")
                return  // Optionally, you could load the image here or show an error
            }

            // Pass data to the destination view controller
            destinationVC.cityImage = image
            destinationVC.cityName = selectedPlace.name
            destinationVC.countryName = selectedPlace.country
            destinationVC.title = selectedPlace.name
        }
    }
    
}

extension PlacesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200 // Fixed height for each cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero // Remove margins
        cell.separatorInset = UIEdgeInsets.zero // Remove space between cells
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageOverlayCell", for: indexPath) as! ImageOverlayTableViewCell
        let place = places[indexPath.row]
        cell.configure(with: place)

        if place.image == nil { // Fetch image if not already loaded
            fetchImageForCity(city: place.name) { image in
                if let image = image {
                    DispatchQueue.main.async {
                        self.places[indexPath.row].image = image
                        cell.cityImageView.image = image
                    }
                }
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Example of manually triggering a segue
        performSegue(withIdentifier: "showDetailsSegue", sender: indexPath)
    }
    
    
}

extension PlacesViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            places.removeAll() // Clear current places to prepare for new data
            placesTableView.reloadData() // Refresh the table view to show empty state or loading state
            
            guard let searchText = searchBar.text, !searchText.isEmpty else {
                return
            }
            
            navigationItem.searchController?.dismiss(animated: true)
            indicator.startAnimating() // Show loading indicator
            
            Task {
                await searchPlaces(named: searchText)
            }
        }
}
