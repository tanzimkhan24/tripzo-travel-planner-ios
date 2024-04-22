//
//  StartPageViewController.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 22/4/2024.
//

import UIKit

class StartPageViewController: UIViewController, UIScrollViewDelegate {
    
    var scrollView: UIScrollView!

    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var textDescription: UILabel!
    
    let titleTexts = ["Discover Your Next Adventure", "Trip Planning at the Palm of your hand", "Save and Plan Your Adventures"]
    let textDescriptionTexts = ["Tripzo curates travel gems just for you. Get personalized destination recommendations and start building your dream journey.","Let us plan your trip tailored to your preferences. Easy planning for unforgettable experience","Found your dream destination? Add it to your saved list for later. Tripzo keeps your travel dreams organized and within reach."]
        
    var autoScrollTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupScrollView()
        pageControl.numberOfPages = titleTexts.count
        pageControl.currentPage = 0
        updatText()
        startAutoScroll()
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
        updatText()
        resetAutoScrollTimer()
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        autoScrollTimer?.invalidate()
    }
    
    func setupScrollView() {
            scrollView = UIScrollView(frame: .zero) // Frame will be set using Auto Layout.
            scrollView.isPagingEnabled = true
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.delegate = self
            view.addSubview(scrollView)

            // Set Auto Layout constraints for the scroll view
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                scrollView.bottomAnchor.constraint(equalTo: pageControl.topAnchor)
            ])
    }
    
    
    @IBAction func pageControlDidChange(_ sender: UIPageControl) {
        
        scrollView.setContentOffset(CGPoint(x: CGFloat(sender.currentPage) * scrollView.bounds.width, y: 0), animated: true)
        resetAutoScrollTimer()
    }
    
    func updatText() {
            let currentPage = pageControl.currentPage
            textLabel.text = titleTexts[currentPage]
        textDescription.text = textDescriptionTexts[currentPage]
        }

    func startAutoScroll() {
            autoScrollTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
                self?.advancePage()
            }
        }

    func advancePage() {
        let nextPage = (pageControl.currentPage + 1) % titleTexts.count
        let offset = CGPoint(x: CGFloat(nextPage) * scrollView.bounds.width, y: 0)
        scrollView.setContentOffset(offset, animated: true)
        pageControl.currentPage = nextPage
        updatText()
    }

    func resetAutoScrollTimer() {
        
        autoScrollTimer?.invalidate()
        startAutoScroll()
        
    }

    
}
