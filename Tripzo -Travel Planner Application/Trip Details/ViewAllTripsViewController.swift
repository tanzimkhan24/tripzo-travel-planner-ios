//
//  ViewAllTripsViewController.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 22/5/2024.
//

import UIKit
import MapKit
import CoreLocation

class ViewAllTripsViewController: UIViewController,MKMapViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    var selectedAttractions: [Attraction] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        displayAttractionsOnMap()
        
        let nib = UINib(nibName: "AttractionTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "AttractionCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
    }
    
    func displayAttractionsOnMap() {
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
}

extension ViewAllTripsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedAttractions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AttractionCell", for: indexPath) as! AttractionTableViewCell
        let attraction = selectedAttractions[indexPath.row]
        cell.configure(with: attraction)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let attraction = selectedAttractions[indexPath.row]
        let coordinate = CLLocationCoordinate2D(latitude: attraction.latitude, longitude: attraction.longitude)
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        
        print("Selected attraction: \(attraction.title)")
        print("Latitude: \(attraction.latitude), Longitude: \(attraction.longitude)")
        mapView.setRegion(region, animated: true)
    }
}
