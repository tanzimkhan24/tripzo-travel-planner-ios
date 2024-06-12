//
//  PopularAttractionDetailsViewController.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 12/6/2024.
//

import UIKit

class PopularAttractionDetailsViewController: UIViewController {

    @IBOutlet weak var attractionNameLabel: UILabel!
    
    @IBOutlet weak var attractionDescription: UITextView!
    
    @IBOutlet weak var attractionImageCollectionView: UICollectionView!
    
    var reviews: [Review] = [] {
        didSet {
            DispatchQueue.main.async {
                self.reviewTableView.reloadData()
            }
        }
    }
    
    var placePhotos: [UnsplashPhoto] = []
    
    
    
    var attractionName: String?
    var attractioDescription: String? {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var reviewTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attractionDescription.layer.cornerRadius = 20
        attractionNameLabel.text = attractionName
        reviewTableView.delegate = self
        reviewTableView.dataSource = self
        attractionImageCollectionView.delegate = self
        attractionImageCollectionView.dataSource = self
        attractionImageCollectionView.register(UINib(nibName: "TripGalleryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TripGalleryCollectionViewCell")
        updateUI()
        
        if let name = attractionName {
            fetchImages(for: name) {
                print("Images fetched successfully")
            }
        }

        // Do any additional setup after loading the view.
    }
    
    func updateUI() {
        
        DispatchQueue.main.async {
            self.attractionDescription?.text = self.attractioDescription
            self.reviewTableView.reloadData()
        }

    }
    
    func fetchImages(for query: String, completion: @escaping () -> Void) {
        let urlString = "https://api.unsplash.com/search/photos?page=1&query=\(query)&client_id=UY7coixlm6n8n7ktFzmSYkt89mUlNp6BUEmDK0s6Dlk"
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to fetch images: \(error?.localizedDescription ?? "Unknown error")")
                completion()
                return
            }
            
            do {
                let response = try JSONDecoder().decode(UnsplashSearchResult.self, from: data)
                self.placePhotos = response.results
                DispatchQueue.main.async {
                    self.attractionImageCollectionView.reloadData()
                    completion()
                }
            } catch {
                print("Failed to decode images response: \(error)")
                completion()
            }
        }.resume()
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

extension PopularAttractionDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewTableViewCell
        let review = reviews[indexPath.row]
        cell.configure(with: review)
        return cell
    }
    
    
}

extension PopularAttractionDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return placePhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TripGalleryCollectionViewCell", for: indexPath) as! TripGalleryCollectionViewCell
        let photo = placePhotos[indexPath.item]
        cell.configure(with: photo)
        return cell
    }
}
