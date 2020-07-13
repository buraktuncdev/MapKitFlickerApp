//
//  Constants.swift
//  FlickrMapApp
//
//  Created by Burak Tunc on 24.06.2020.
//  Copyright © 2020 Burak Tunç. All rights reserved.
//

import Foundation

let apiKey = "316637240154b3d1e3a7eb3532706774"


func flickrURL(forApiKey key: String, withAnnotation annotation:DroppablePin, addNumberOfPhotos number: Int) -> String{
    let url = "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.latitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
    print(url)
    return url
}


