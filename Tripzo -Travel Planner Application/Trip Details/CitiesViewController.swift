//
//  CitiesViewController.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 10/6/2024.
//

import UIKit

struct City {
    let name: String
    let country: String
    let imageUrl: String
    let latitude: Double
    let longitude: Double
}

class CitiesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var citiesCollectionView: UICollectionView!
    @IBOutlet weak var weatherCollectionView: UICollectionView!
    
    var cities: [City] = []
    var weatherForecast: [DailyWeather] = []
    var activityIndicator = UIActivityIndicatorView(style: .large)
    weak var placesViewController: PlacesViewController?
    var selectedCityName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        citiesCollectionView.layer.cornerRadius = 15
        
        citiesCollectionView.dataSource = self
        citiesCollectionView.delegate = self
        weatherCollectionView.dataSource = self
        weatherCollectionView.delegate = self
        citiesCollectionView.register(UINib(nibName: "SelectedTripsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SelectedTripCell")
        weatherCollectionView.register(UINib(nibName: "WeatherForecastCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WeatherCell")
        
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
    
    func fetchWeatherData(lat: Double, lon: Double) {
        let apiKey = "b010125edc999872f3e6e84f33237297"
        let urlString = "https://api.openweathermap.org/data/3.0/onecall?lat=\(lat)&lon=\(lon)&exclude=minutely,hourly,alerts&appid=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                }
                print("Error fetching weather data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            do {
                let forecast = try JSONDecoder().decode(WeatherForecast.self, from: data)
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    self?.weatherForecast = Array(forecast.daily.prefix(7))
                    self?.weatherCollectionView.reloadData()
                }
            } catch {
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                }
                print("Error parsing weather data: \(error)")
            }
        }.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addTrips" {
            if let destinationVC = segue.destination as? SuggestedTripsViewController {
                destinationVC.cityName = selectedCityName
            }
        }
    }
    
    @IBAction func addTripsPressed(_ sender: Any) {
        performSegue(withIdentifier: "addTrips", sender: self)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case citiesCollectionView:
            return cities.count
        case weatherCollectionView:
            return weatherForecast.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == citiesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectedTripCell", for: indexPath) as! SelectedTripsCollectionViewCell
            let city = cities[indexPath.item]
            cell.configure(with: city)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherCell", for: indexPath) as! WeatherForecastCollectionViewCell
            let weather = weatherForecast[indexPath.item]
            cell.configure(with: weather)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == citiesCollectionView {
            let selectedCity = cities[indexPath.item]
            selectedCityName = selectedCity.name
            fetchWeatherData(lat: selectedCity.latitude, lon: selectedCity.longitude)
            placesViewController?.panToCity(latitude: selectedCity.latitude, longitude: selectedCity.longitude, cityName: selectedCity.name)
        }
    }
}

