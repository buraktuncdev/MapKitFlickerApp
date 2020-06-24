//
//  ViewController.swift
//  FlickrMapApp
//
//  Created by Burak Tunc on 23.06.2020.
//  Copyright © 2020 Burak Tunç. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController, UIGestureRecognizerDelegate{
    
    // Customize Pin
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // We need Our Location is default
        if annotation is MKUserLocation {
            return nil
        }
        
        // Double Tap Pinner Design
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.9771530032, green: 0.7062081099, blue: 0.1748393774, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }

    // Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var pullUpView: UIView!
    @IBOutlet weak var mapViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!
    // Variables
    var locationManager = CLLocationManager()                            // location manager variable
    let authorizationStatus = CLLocationManager.authorizationStatus()    // Authorization status for CLLocation Services
    let regionRadius: Double = 2000                                     // 2000 meters for region
    
    var spinner:UIActivityIndicatorView?
    var progressLabel:UILabel?
    
    var screenSize = UIScreen.main.bounds // Screen Size
    
    var flowLayout = UICollectionViewFlowLayout()
    var collectionView: UICollectionView?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        addDoubleTap()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = .green
        
        pullUpView.addSubview(collectionView!)
        
    }
    
    // Douple Tap Gesture Recognizer for the Point as X,Y
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2 // count of taps
        doubleTap.delegate = self          // UIGestureRecognizerDelegate
        mapView.addGestureRecognizer(doubleTap)
    }
    
    func addSpinner() {
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width / 2) - ((spinner?.frame.width)! / 2), y: 200)
        spinner?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.large
        spinner?.color = .darkGray
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)
    }
    
    // Adding SwipeGestureRecognizer down
    func addSwipe(){
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe) // Add Gesture Recognizer
    }
    
    // Down Animate of Image View
    @objc func animateViewDown() {
        pullUpViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    // UIGestureRecognizer sender implements because we need to catch and convert(to GPS) that coordinates of double tap point
    @objc func dropPin(sender: UIGestureRecognizer) {
        removePin()
        removeSpinner()
        removeProgressLabel()
        
        animateViewUp()   // When we drop pin pull up the image collection view
        addSwipe()        // Swipe down
        addSpinner()      // When Double Tap new Spinner appears
        addProgressLabel()
        
        
        
        let touchPoint = sender.location(in: mapView)                                // touch point X,Y
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView) // Converting to GPS coordinates
        
        print(touchCoordinate)
        
        // Add Pin to MapView
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotation)
        
        print(flickrURL(forApiKey: apiKey, withAnnotation: annotation, addNumberOfPhotos: 40))
        
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    // Pull up the image view
    func animateViewUp() {
        pullUpViewHeightConstraint.constant = 400
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func removePin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
    
    func removeSpinner() {
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    
    func addProgressLabel(){
        progressLabel = UILabel()
        progressLabel?.frame = CGRect(x: (screenSize.width / 2) - 120, y: 225, width: 240, height: 40)
        progressLabel?.font = UIFont(name: "Avenir Next", size: 18)
        progressLabel?.textColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        progressLabel?.textAlignment = .center
        progressLabel?.text = "..."
        collectionView?.addSubview(progressLabel!)
    }
    
    func removeProgressLabel() {
        if progressLabel != nil {
            progressLabel?.removeFromSuperview()
        }
    }
    
    
    // Center Location
    @IBAction func centerMapButtonPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
    

}

extension MapVC: CLLocationManagerDelegate {
    
    // Configuration of Location Services
    func configureLocationServices() {
        if authorizationStatus == .notDetermined{        // May be denied or not approved
            locationManager.requestAlwaysAuthorization() // Request always authorization
        } else {
            return
        }
    }
    
    // Authorization Status Event
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
    
}

extension MapVC: MKMapViewDelegate {
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else {return}
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}

extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell
        return cell!
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
}
