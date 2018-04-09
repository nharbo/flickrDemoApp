//
//  MapController.swift
//  FlickrDemoApp
//
//  Created by Nicolai Harbo on 08/04/2018.
//  Copyright © 2018 nicoware. All rights reserved.
//

import Foundation

class MapController {
    
    //MARK: - Constants
    let flickr = FlickrManager.sharedInstance
    
    //MARK: - Variables
    var allImages = [Image]()
    
    //MARK: - Structs for callbacks
    struct CallbackStatus {
        var success: Bool
        var error: NSError?
    }
    
    //MARK: - Setters
    
    //MARK: - Getters
    func getAllImages() -> [Image] {
        for pubImage in flickr.getPublicImages() {
            self.allImages.append(pubImage)
        }
        for ownImage in flickr.getOwnImages() {
            self.allImages.append(ownImage)
        }
        return allImages
    }
    
    
    
}
