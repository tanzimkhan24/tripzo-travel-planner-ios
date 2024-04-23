//
//  StartPageViewController.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 22/4/2024.
//

import UIKit

class StartPageViewController: UIViewController {
    
    @IBOutlet weak var semiCircleView: SemiCircleView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var nextButton: UIButton!
    
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        
        if currentPage == slides.count - 1 {
            print("Go to next page")
        } else {
            currentPage += 1
            let indexPath = IndexPath(item: currentPage, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            
        }
        
    }
        
    
    var slides: [StartScreenSlide] = []
    
    var currentPage = 0 {
            didSet {
                pageControl.currentPage = currentPage
                if currentPage == slides.count - 1 {
                    nextButton.setTitle("Get Started", for: .normal)
                } else {
                    nextButton.setTitle("Next", for: .normal)
                }
            }
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .clear
        
        view.bringSubviewToFront(semiCircleView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        slides = [
            StartScreenSlide(title: "Discover Your Next Adventure", description: "Tripzo curates travel gems just for you. Get personalized destination recommendations and start building your dream journey.",image: .screen1),
            StartScreenSlide(title: "Trip Planning at the Palm of your hand", description: "Let us plan your trip tailored to your preferences. Easy planning for unforgettable experience",image: .screen2),
            StartScreenSlide(title: "Save and Plan Your Adventures", description: "Found your dream destination? Add it to your saved list for later. Tripzo keeps your travel dreams organized and within reach.",image: .screen1)
        ]
        
        pageControl.numberOfPages = slides.count
        
        
    }
    
    
    
    
}

extension StartPageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "startScreenCollectionViewCell", for: indexPath) as! StartScreenCollectionViewCell
        cell.setup(slides[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            let width = scrollView.frame.width
            currentPage = Int(scrollView.contentOffset.x / width)
    }
    
    
    
}
