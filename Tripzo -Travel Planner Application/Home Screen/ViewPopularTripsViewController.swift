//
//  ViewPopularTripsViewController.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 12/6/2024.
//

import UIKit
import MapKit
import FloatingPanel

class ViewPopularTripsViewController: UIViewController, MKMapViewDelegate, FloatingPanelControllerDelegate {
    
    var mapView = MKMapView()
    var attractionLocation = CLLocationCoordinate2D()
    var attractionName: String?
    var attractionDescription: String?
    var userLocation = CLLocationCoordinate2D()
    var floatingPanelController: FloatingPanelController!
    var placeID: String? // Place ID of the selected location
    var review: [Review] = []
    var placePhotos: [UnsplashPhoto] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        setupUI()
        configureConstraints()
        setupNavigationBar()
        setupMap()
        setupFloatingPanel()
        
        if let placeID = placeID {
            fetchPlaceDetails(for: placeID)
        }
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
    
    func setupNavigationBar() {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
              let statusBarHeight = window.windowScene?.statusBarManager?.statusBarFrame.height else {
            return
        }

        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: (navigationController?.navigationBar.frame.height)! + statusBarHeight)
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(blurEffectView)
        view.bringSubviewToFront(navigationController!.navigationBar)

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    func setupMap() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = attractionLocation
        annotation.title = attractionName
        mapView.addAnnotation(annotation)
        
        let coordinates: [CLLocationCoordinate2D] = [userLocation, attractionLocation]
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polyline)
        
        zoomOutToShowBothLocations(userLocation: userLocation, attractionLocation: attractionLocation)
    }
    
    func setupFloatingPanel() {
        floatingPanelController = FloatingPanelController()
        floatingPanelController.delegate = self
        
        guard let placeDetailVC = storyboard?.instantiateViewController(withIdentifier: "PopularAttractionDetailsViewController") as? PopularAttractionDetailsViewController else { return }
        placeDetailVC.attractionName = attractionName
        
        // Fetch Wikipedia summary and set it to the detail view controller
        if let attractionName = attractionName {
            fetchWikipediaSummary(for: attractionName) { summary in
                DispatchQueue.main.async {
                    placeDetailVC.attractionDescription.text = summary ?? "No description available"
                    placeDetailVC.reviews = self.review
                    placeDetailVC.reviewTableView.reloadData()
                }
            }
        }
        
        floatingPanelController.set(contentViewController: placeDetailVC)
        floatingPanelController.addPanel(toParent: self)
    }
    
    func fetchWikipediaSummary(for title: String, completion: @escaping (String?) -> Void) {
        let urlString = "https://en.wikipedia.org/api/rest_v1/page/summary/\(title)"
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            do {
                let response = try JSONDecoder().decode(WikipediaSummary.self, from: data)
                completion(response.extract)
            } catch {
                completion(nil)
            }
        }
        task.resume()
    }
    
    func fetchPlaceDetails(for placeID: String) {
        let apiKey = "AIzaSyDLpWZCxK62J2vMItzi_yGuyCfMfdFgeeA"
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(placeID)&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching place details: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let placeDetailsResponse = try JSONDecoder().decode(GooglePlaceDetailsResponse.self, from: data)
                let reviews = placeDetailsResponse.result.reviews ?? []
                self.review.append(contentsOf: reviews)

            } catch {
                print("Error decoding response: \(error)")
            }
        }
        task.resume()
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 4.0
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "attractionLocation"
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
            return annotationView
        } else {
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView.canShowCallout = true
            return annotationView
        }
    }
    
    func zoomOutToShowBothLocations(userLocation: CLLocationCoordinate2D, attractionLocation: CLLocationCoordinate2D) {
        var zoomRect = MKMapRect.null
        let userPoint = MKMapPoint(userLocation)
        let attractionPoint = MKMapPoint(attractionLocation)
        
        let userRect = MKMapRect(x: userPoint.x, y: userPoint.y, width: 0.1, height: 0.1)
        let attractionRect = MKMapRect(x: attractionPoint.x, y: attractionPoint.y, width: 0.1, height: 0.1)
        
        zoomRect = zoomRect.union(userRect)
        zoomRect = zoomRect.union(attractionRect)
        
        mapView.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40), animated: true)
    }
}

// Define the structures for decoding the JSON response
struct GooglePlaceDetailsResponse: Codable {
    let result: PlaceDetailsResult
}

struct PlaceDetailsResult: Codable {
    let reviews: [Review]?
}

struct Review: Codable {
    let author_name: String
    let rating: Int
    let text: String
}

