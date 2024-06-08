//
//  SuggestedTripsViewController.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 8/5/2024.
//

import UIKit
import SDWebImage
import MapKit

class SuggestedTripsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var cityName: String?
    var attractions: [Attraction] = []
    var selectedAttractions: [Attraction] = []
    var indicator = UIActivityIndicatorView()
    

    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "AttractionTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "AttractionCell")

        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = true
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.systemGroupedBackground


        setupActivityIndicator()

        fetchAttractionsData()
    }

    func setupActivityIndicator() {
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.style = .large
        view.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }

    func fetchAttractionsData() {
        guard let cityName = cityName else { return }
        indicator.startAnimating() // Start the activity indicator
        
        fetchAttractions(for: cityName) { [weak self] result in
            DispatchQueue.main.async {
                self?.indicator.stopAnimating() // Stop the activity indicator
                switch result {
                case .success(let attractions):
                    self?.attractions = attractions
                    self?.tableView.reloadData()
                case .failure(let error):
                    print("Error fetching attractions: \(error.localizedDescription)")
                    let alert = UIAlertController(title: "Error", message: "Failed to fetch attractions. Please try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attractions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AttractionCell", for: indexPath) as! AttractionTableViewCell
        let attraction = attractions[indexPath.row]
        cell.configure(with: attraction)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedAttraction = attractions[indexPath.row]
        selectedAttractions.append(selectedAttraction)
        tableView.cellForRow(at: indexPath)?.contentView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let deselectedAttraction = attractions[indexPath.row]
        if let index = selectedAttractions.firstIndex(where: { $0.id == deselectedAttraction.id }) {
            selectedAttractions.remove(at: index)
        }
        tableView.cellForRow(at: indexPath)?.contentView.backgroundColor = UIColor.systemBackground
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMap" {
            if let mapVC = segue.destination as? ViewAllTripsViewController {
                mapVC.selectedAttractions = self.selectedAttractions
            }
        }
    }
    
    
    @IBAction func addTripsPressed(_ sender: Any) {
        
        if selectedAttractions.isEmpty {
            let alert = UIAlertController(title: "No Selection", message: "Please select at least one trip.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        } else {
            performSegue(withIdentifier: "showMap", sender: self)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
