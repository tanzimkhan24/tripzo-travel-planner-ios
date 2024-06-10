//
//  SelectedTripViewController.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 8/5/2024.
//

import UIKit
import MapKit

class SelectedTripViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var addTripsButton: UIButton!
    @IBOutlet weak var fromDateTextField: UITextField!
    @IBOutlet weak var toDateTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var weatherForecastView: UICollectionView!
    
    var activityIndicator: UIActivityIndicatorView!
    var locationManager = CLLocationManager()
    var userLocation: CLLocationCoordinate2D?
    
    struct Location: Codable {
        let name: String
        let lat: Double
        let lon: Double
        let country: String
        let state: String?
    }
    
    var cityImage: UIImage?
    var cityName: String?
    var countryName: String?
    
    var weatherData: [DailyWeather] = []
    var filteredWeatherData: [DailyWeather] = []
    
    var fromDatePicker: UIDatePicker = UIDatePicker()
    var toDatePicker: UIDatePicker = UIDatePicker()
    var cityCoordinates: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        weatherForecastView.register(UINib(nibName: "WeatherForecastCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WeatherCell")
        weatherForecastView.dataSource = self
        weatherForecastView.delegate = self
        
        fromDateTextField.delegate = self
        toDateTextField.delegate = self
        
        fetchCoordinatesAndWeather()
        
        mapView.layer.cornerRadius = 10
        mapView.delegate = self
        
        configureDatePickers()
        setupActivityIndicator()
        setupUI()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func setupUI() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = cityImage
        backgroundImage.contentMode = .scaleAspectFill
        view.insertSubview(backgroundImage, at: 0)

        titleLabel.text = "Get ready to explore \(countryName ?? "this destination")"
        weatherLabel.text = "Current Weather in \(cityName ?? "this location")"
        
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(2).cgColor]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        view.layer.insertSublayer(gradient, above: backgroundImage.layer)

        fromDateTextField.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        toDateTextField.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        fromDateTextField.textColor = .black
        toDateTextField.textColor = .black

        addTripsButton.layer.cornerRadius = 22
        addTripsButton.clipsToBounds = true
        addTripsButton.backgroundColor = UIColor.systemBlue
        addTripsButton.setTitleColor(.white, for: .normal)
        addTripsButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        weatherForecastView.backgroundColor = UIColor.clear
    }

    func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
    }
    
    func configureDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale(identifier: "en_AU")
        return formatter
    }

    func configureDatePickers() {
        fromDatePicker.datePickerMode = .date
        fromDatePicker.preferredDatePickerStyle = .inline
        fromDatePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        fromDateTextField.inputView = fromDatePicker

        toDatePicker.datePickerMode = .date
        toDatePicker.preferredDatePickerStyle = .inline
        toDatePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        toDateTextField.inputView = toDatePicker
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissDatePicker))
            
        toolbar.setItems([flexSpace, doneButton], animated: true)
        fromDateTextField.inputAccessoryView = toolbar
        toDateTextField.inputAccessoryView = toolbar
    }
    
    @objc func dismissDatePicker() {
        view.endEditing(true)

        let formatter = configureDateFormatter()
        if let fromDateText = fromDateTextField.text, !fromDateText.isEmpty,
           let toDateText = toDateTextField.text, !toDateText.isEmpty,
           let fromDate = formatter.date(from: fromDateText),
           let toDate = formatter.date(from: toDateText) {
            filterWeatherData(fromDate: fromDate, toDate: toDate)
        } else {
            filteredWeatherData = Array(weatherData.prefix(7))
        }
        
        DispatchQueue.main.async {
            self.weatherForecastView.reloadData()
        }
    }

    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"

        if sender == fromDatePicker {
            fromDateTextField.text = formatter.string(from: sender.date)
            toDatePicker.minimumDate = sender.date.addingTimeInterval(86400)
        } else if sender == toDatePicker {
            toDateTextField.text = formatter.string(from: sender.date)
        }

        if let fromDateText = fromDateTextField.text, let toDateText = toDateTextField.text,
           let fromDate = formatter.date(from: fromDateText), let toDate = formatter.date(from: toDateText) {
            updateWeatherDataForSelectedDates(fromDate: fromDate, toDate: toDate)
        }
    }
    
    func fetchCoordinates(for cityName: String, completion: @escaping (Result<(lat: Double, lon: Double), Error>) -> Void) {
        let apiKey = "b010125edc999872f3e6e84f33237297"
        let urlString = "https://api.openweathermap.org/geo/1.0/direct?q=\(cityName)&limit=1&appid=\(apiKey)"
        
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let locations = try JSONDecoder().decode([Location].self, from: data)
                guard let location = locations.first else {
                    completion(.failure(NSError(domain: "NoLocationFound", code: 2, userInfo: [NSLocalizedDescriptionKey: "No location found with that name"])))
                    return
                }
                
                completion(.success((lat: location.lat, lon: location.lon)))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchCoordinatesAndWeather() {
        guard let city = cityName else { return }
        fetchCoordinates(for: city) { [weak self] result in
            switch result {
            case .success(let location):
                self?.cityCoordinates = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lon)
                DispatchQueue.main.async {
                    self?.centerMapOnCountry(location: self?.cityCoordinates)
                }
                self?.fetchWeatherData(lat: location.lat, lon: location.lon)
            case .failure(let error):
                print("Failed to fetch coordinates: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchWeatherData(lat: Double, lon: Double) {
        DispatchQueue.main.async {
            self.weatherData = []
            self.filteredWeatherData = []
            self.weatherForecastView.reloadData()
            self.activityIndicator.startAnimating()
        }

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
                    self?.weatherData = forecast.daily
                    self?.filteredWeatherData = Array(self?.weatherData.prefix(7) ?? [])
                    self?.weatherForecastView.reloadData()
                }
            } catch {
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                }
                print("Error parsing weather data: \(error)")
            }
        }.resume()
    }

    func filterWeatherData(fromDate: Date, toDate: Date) {
        filteredWeatherData = weatherData.filter { dailyWeather in
            guard let date = dailyWeather.date else { return false }
            return date >= fromDate && date <= toDate
        }
        
        DispatchQueue.main.async {
            self.weatherForecastView.reloadData()
        }
    }

    func updateWeatherDataForSelectedDates(fromDate: Date, toDate: Date) {
        filteredWeatherData = weatherData.filter { dailyWeather in
            guard let date = dailyWeather.date else { return false }
            return date >= fromDate && date <= toDate
        }
        
        DispatchQueue.main.async {
            self.weatherForecastView.reloadData()
        }
    }
    
    func centerMapOnCountry(location: CLLocationCoordinate2D?) {
        guard let location = location else { return }
        let regionRadius: CLLocationDistance = 1000000
        let coordinateRegion = MKCoordinateRegion(center: location, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = cityName
        mapView.addAnnotation(annotation)
        
        if let userLocation = userLocation {
            let userAnnotation = MKPointAnnotation()
            userAnnotation.coordinate = userLocation
            userAnnotation.title = "Your Location"
            mapView.addAnnotation(userAnnotation)
            
            let coordinates = [userLocation, location]
            let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            DispatchQueue.main.async {
                self.mapView.addOverlay(polyline)
            }
            
            let distance = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude).distance(from: CLLocation(latitude: location.latitude, longitude: location.longitude)) / 1000
            DispatchQueue.main.async {
                self.titleLabel.text = "Get ready to explore \(self.countryName ?? "") (\(Int(distance)) km from your location)"
            }
        }
    }
    
    func didSelectDateRange(fromDate: Date, toDate: Date) {
        updateWeatherDataForSelectedDates(fromDate: fromDate, toDate: toDate)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredWeatherData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherCell", for: indexPath) as? WeatherForecastCollectionViewCell else {
            return UICollectionViewCell()
        }
        let weather = filteredWeatherData[indexPath.row]
        cell.configure(with: weather)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addTrips" {
            if let destinationVC = segue.destination as? SuggestedTripsViewController {
                destinationVC.cityName = self.cityName
            }
        }
    }
    
    @IBAction func addTripPressed(_ sender: Any) {
        performSegue(withIdentifier: "addTrips", sender: self)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last?.coordinate {
            userLocation = location
            if let cityCoordinates = cityCoordinates {
                DispatchQueue.main.async {
                    self.centerMapOnCountry(location: cityCoordinates)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }
}

extension SelectedTripViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .blue
            renderer.lineWidth = 4.0
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}
