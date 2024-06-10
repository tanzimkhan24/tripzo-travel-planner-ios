//
//  PlacesViewController.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 1/5/2024.
//

import UIKit
import MapKit
import FloatingPanel

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

struct GoogleGeometry: Codable {
    let location: GoogleLocation
}

struct GoogleLocation: Codable {
    let lat: Double
    let lng: Double
}

class PlacesViewController: UIViewController, FloatingPanelControllerDelegate, MKMapViewDelegate {
    
    var mapView = MKMapView()
    var floatingPanelController: FloatingPanelController!
    var resultsSheetViewController: ResultsSheetViewController?
    var currentPolyline: MKPolyline?
    var currentLocationAnnotation: MKPointAnnotation?
    var destinationAnnotation: MKPointAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupUI()
        configureConstraints()
        setupFloatingPanel()
        showCurrentLocation()
    }
    
    func setupUI() {
        view.addSubview(mapView)
    }
    
    func configureConstraints() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leftAnchor.constraint(equalTo: view.leftAnchor),
            mapView.rightAnchor.constraint(equalTo: view.rightAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setupFloatingPanel() {
        floatingPanelController = FloatingPanelController()
        floatingPanelController.delegate = self
        
        if let resultsVC = storyboard?.instantiateViewController(withIdentifier: "ResultsSheetViewController") as? ResultsSheetViewController {
            floatingPanelController.set(contentViewController: resultsVC)
            resultsSheetViewController = resultsVC
            resultsSheetViewController?.placesViewController = self
        }
        
        floatingPanelController.addPanel(toParent: self)
        floatingPanelController.move(to: .tip, animated: false)
    }
    
    func showCurrentLocation() {
        if let currentLocation = LocationManager.shared.manager.location {
            let annotation = MKPointAnnotation()
            annotation.coordinate = currentLocation.coordinate
            annotation.title = "Current Location"
            mapView.addAnnotation(annotation)
            mapView.setRegion(MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000), animated: true)
            currentLocationAnnotation = annotation
        }
    }
    
    func annotateCountry(latitude: Double, longitude: Double, name: String) {
        if let currentPolyline = currentPolyline {
            mapView.removeOverlay(currentPolyline)
        }
        
        if let destinationAnnotation = destinationAnnotation {
            mapView.removeAnnotation(destinationAnnotation)
        }
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        annotation.title = name
        mapView.addAnnotation(annotation)
        destinationAnnotation = annotation
        
        if let userLocation = LocationManager.shared.manager.location {
            let userCoordinate = userLocation.coordinate
            let destinationCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let coordinates = [userCoordinate, destinationCoordinate]
            currentPolyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            
            mapView.setVisibleMapRect(mapView.visibleMapRect.union(MKPolyline(coordinates: coordinates, count: coordinates.count).boundingMapRect), animated: true)
            
            let distance = userLocation.distance(from: CLLocation(latitude: latitude, longitude: longitude)) / 1000
            resultsSheetViewController?.distanceLabel.text = String(format: "%.0f km", distance)
        }
    }
    
    func showPolyline() {
        if let currentPolyline = currentPolyline {
            mapView.addOverlay(currentPolyline)
        }
    }
    
    func panToCity(latitude: Double, longitude: Double, cityName: String) {
        let cityCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = cityCoordinate
        annotation.title = cityName
        mapView.addAnnotation(annotation)
        mapView.setRegion(MKCoordinateRegion(center: cityCoordinate, latitudinalMeters: 10000, longitudinalMeters: 10000), animated: true)
    }
    
    func showAllCities(cities: [City]) {
        mapView.removeAnnotations(mapView.annotations)
        var coordinates: [CLLocationCoordinate2D] = []
        for city in cities {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: city.latitude, longitude: city.longitude)
            annotation.title = city.name
            mapView.addAnnotation(annotation)
            coordinates.append(annotation.coordinate)
        }
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polyline)
        mapView.setVisibleMapRect(polyline.boundingMapRect, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 3
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}
