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

class MapVC: UIViewController{

    // Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    // Variables
    var locationManager = CLLocationManager()                            // location manager variable
    let authorizationStatus = CLLocationManager.authorizationStatus()    // Authorization status for CLLocation Services
    let regionRadius: Double = 1000                                   // 1000 meters for region
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
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

