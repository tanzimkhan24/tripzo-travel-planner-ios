//
//  ViewAllTripsViewController.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 22/5/2024.
//

import UIKit
import MapKit
import CoreLocation

class ViewAllTripsViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    var selectedAttractions: [Attraction] = []
    var itineraries: [Itinerary] = []
    weak var homeScreenViewController: HomeScreenViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupMapView()
        collectionView.delegate = self
        collectionView.dataSource = self
        let nib = UINib(nibName: "SelectedTripsCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "SelectedTripCell")
        
        if selectedAttractions.isEmpty {
            showNoTripsMessage()
        } else {
            displayAttractionsOnMap()
        }
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressRecognizer.minimumPressDuration = 1.0 // Duration in seconds
        collectionView.addGestureRecognizer(longPressRecognizer)
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
    
    func setupMapView() {
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    
    func displayAttractionsOnMap() {
        mapView.removeAnnotations(mapView.annotations) // Remove existing annotations
        for attraction in selectedAttractions {
            let annotation = MKPointAnnotation()
            annotation.title = attraction.title
            annotation.coordinate = CLLocationCoordinate2D(latitude: attraction.latitude, longitude: attraction.longitude)
            mapView.addAnnotation(annotation)
        }
        
        if let firstAttraction = selectedAttractions.first {
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: firstAttraction.latitude, longitude: firstAttraction.longitude), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            mapView.setRegion(region, animated: true)
        }
    }
    
    func removeAnnotation(for attraction: Attraction) {
        let annotations = mapView.annotations.filter {
            $0.coordinate.latitude == attraction.latitude && $0.coordinate.longitude == attraction.longitude
        }
        mapView.removeAnnotations(annotations)
    }
    
    func showNoTripsMessage() {
        let alert = UIAlertController(title: "No Trips", message: "No trips from this city exist. Please return to the previous screen to add some.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func createTripPressed(_ sender: Any) {
        guard let firstAttraction = selectedAttractions.first else { return }
        let itinerary = Itinerary(cityName: firstAttraction.cityName, countryName: firstAttraction.countryName, attractions: selectedAttractions)
        var savedItineraries = loadItineraries()
        savedItineraries.append(itinerary)
        saveItineraries(savedItineraries)
        
        homeScreenViewController?.itineraries = savedItineraries

        let alert = UIAlertController(title: "Trip Created", message: "Your trip has been created successfully.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            if let homeVC = self.navigationController?.viewControllers.first(where: { $0 is HomeScreenViewController }) as? HomeScreenViewController {
                homeVC.itineraries = savedItineraries
                self.navigationController?.popToViewController(homeVC, animated: true)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }))
        present(alert, animated: true)
    }
    // MKMapViewDelegate method for clustering
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier, for: annotation) as? MKMarkerAnnotationView
        annotationView?.clusteringIdentifier = "cluster"
        return annotationView
    }
    
    func saveItineraries(_ itineraries: [Itinerary]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(itineraries) {
            UserDefaults.standard.set(encoded, forKey: "itineraries")
        }
    }
    
    func loadItineraries() -> [Itinerary] {
        if let savedItineraries = UserDefaults.standard.object(forKey: "itineraries") as? Data {
            let decoder = JSONDecoder()
            if let loadedItineraries = try? decoder.decode([Itinerary].self, from: savedItineraries) {
                return loadedItineraries
            }
        }
        return []
    }
    
    // UICollectionViewDataSource methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedAttractions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectedTripCell", for: indexPath) as! SelectedTripsCollectionViewCell
        let attraction = selectedAttractions[indexPath.row]
        cell.configure(with: attraction)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let attraction = selectedAttractions[indexPath.row]
        let coordinate = CLLocationCoordinate2D(latitude: attraction.latitude, longitude: attraction.longitude)
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        mapView.setRegion(region, animated: true)
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state != .began {
            return
        }
        
        let point = gesture.location(in: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: point) {
            let attraction = selectedAttractions[indexPath.item]
            
            let alert = UIAlertController(title: "Delete Trip", message: "Are you sure you want to delete the trip to \(attraction.title)?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                self.selectedAttractions.remove(at: indexPath.item)
                self.collectionView.deleteItems(at: [indexPath])
                self.displayAttractionsOnMap()
                
                if self.selectedAttractions.isEmpty {
                    self.showNoTripsMessage()
                }
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
}
