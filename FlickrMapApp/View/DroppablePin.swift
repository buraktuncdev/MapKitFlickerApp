//
//  DroppablePin.swift
//  FlickrMapApp
//
//  Created by Burak Tunc on 23.06.2020.
//  Copyright © 2020 Burak Tunç. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class DroppablePin: NSObject, MKAnnotation {
    
    dynamic var coordinate: CLLocationCoordinate2D // Dyanmic Variables are able to be modified the way that we need to create these MKAnnotations
    var identifier: String
    
    init(coordinate: CLLocationCoordinate2D, identifier: String) {
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()
    }
    
   
    
    
}
