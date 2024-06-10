//
//  ItineraryDetailsViewController.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 9/6/2024.
//

import UIKit
import MapKit

class ItineraryDetailsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    
    @IBOutlet weak var tripsCollectionView: UICollectionView!
    
    @IBOutlet weak var tripLabel: UILabel!
    
    var itinerary: Itinerary!
    var tripLabelText: String?
    weak var homeScreenViewController: HomeScreenViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupMapView()
        tripsCollectionView.delegate = self
        tripsCollectionView.dataSource = self
        
        let nib = UINib(nibName: "SelectedTripsCollectionViewCell", bundle: nil)
        tripsCollectionView.register(nib, forCellWithReuseIdentifier: "SelectedTripCell")
        
        if let tripLabelText = tripLabelText {
            tripLabel.text = tripLabelText
        }
        
        displayAttractionsOnMap()
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressRecognizer.minimumPressDuration = 1.0 // Duration in seconds
        tripsCollectionView.addGestureRecognizer(longPressRecognizer)
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
        for attraction in itinerary.attractions {
            let annotation = MKPointAnnotation()
            annotation.title = attraction.title
            annotation.coordinate = CLLocationCoordinate2D(latitude: attraction.latitude, longitude: attraction.longitude)
            mapView.addAnnotation(annotation)
        }
        
        if let firstAttraction = itinerary.attractions.first {
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: firstAttraction.latitude, longitude: firstAttraction.longitude), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            mapView.setRegion(region, animated: true)
        }
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state != .began {
            return
        }

        let point = gesture.location(in: tripsCollectionView)
        if let indexPath = tripsCollectionView.indexPathForItem(at: point) {
            let alert = UIAlertController(title: "Delete Attraction", message: "Are you sure you want to delete this attraction?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                self.itinerary.attractions.remove(at: indexPath.item)
                self.tripsCollectionView.deleteItems(at: [indexPath])
                self.displayAttractionsOnMap()
                
                // Update the itinerary in the HomeScreenViewController
                if let homeVC = self.homeScreenViewController {
                    if let index = homeVC.itineraries.firstIndex(where: { $0.cityName == self.itinerary.cityName && $0.countryName == self.itinerary.countryName }) {
                        if self.itinerary.attractions.isEmpty {
                            homeVC.itineraries.remove(at: index)
                        } else {
                            homeVC.itineraries[index] = self.itinerary
                        }
                        homeVC.saveItineraries(homeVC.itineraries)
                    }
                }
                
                if self.itinerary.attractions.isEmpty {
                    self.navigationController?.popViewController(animated: true)
                }
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func showNoAttractionsMessage() {
        let alert = UIAlertController(title: "No Attractions", message: "No attractions exist. Please return to the previous screen to add some.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itinerary.attractions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectedTripCell", for: indexPath) as! SelectedTripsCollectionViewCell
        let attraction = itinerary.attractions[indexPath.row]
        cell.configure(with: attraction)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let attraction = itinerary.attractions[indexPath.row]
        let coordinate = CLLocationCoordinate2D(latitude: attraction.latitude, longitude: attraction.longitude)
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        mapView.setRegion(region, animated: true)
    }
}
