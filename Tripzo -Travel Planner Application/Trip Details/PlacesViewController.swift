//
//  PlacesViewController.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 1/5/2024.
//

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

import UIKit
import MapKit
import FloatingPanel

class PlacesViewController: UIViewController, FloatingPanelControllerDelegate, MKMapViewDelegate {

    var mapView = MKMapView()
    var floatingPanelController: FloatingPanelController!
    var resultsSheetViewController: ResultsSheetViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupUI()
        configureConstraints()
        setupFloatingPanel()
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

    func annotateCountry(latitude: Double, longitude: Double, name: String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        annotation.title = name
        mapView.addAnnotation(annotation)
        mapView.setRegion(MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 500000, longitudinalMeters: 500000), animated: true)
    }
    
}
