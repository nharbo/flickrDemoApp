//
//  Image.swift
//  FlickrDemoApp
//
//  Created by Nicolai Harbo on 05/04/2018.
//  Copyright © 2018 nicoware. All rights reserved.
//

import Foundation
import MapKit

class Image: NSObject, MKAnnotation {
    
    var id: String?
    var imageUrl: String?
    var owner: String?
    var title: String?
    var lat: Double?
    var long: Double?
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(lat!, long!)
    }
    
    var mapTitle: String? {
        return title
    }
    
    var subtitle: String? {
        return owner
    }
    
}

