//
//  getRecentPublicImages.swift
//  FlickrDemoApp
//
//  Created by Nicolai Harbo on 10/04/2018.
//  Copyright © 2018 nicoware. All rights reserved.
//

import Foundation

class getRecentPublicImages {
    
    //MARK: - Constants
    let flickrManager = FlickrManager.sharedInstance
    let numberOfPublicImages = "100" //A page goes from 1 - 100 elements
    
    //MARK: - Structs
    struct CallStatus {
        var success: Bool
        var error: String?
    }
    
    //Gets the most recent images, and saves them as an Image object including geolocation and image url
    func fetch(callback: @escaping (CallStatus) -> Void){
        
        let parameters :Dictionary = [
            "method"         : "flickr.photos.getRecent",
            "api_key"        : flickrManager.getApiKey(),
            "per_page"       : numberOfPublicImages,
            "format"         : "json",
            "nojsoncallback" : "1",
            "extras"         : "url_q,url_z,geo"
        ]
        let _ = flickrManager.getOauth().client.get(
            flickrManager.getBaseUrl(), parameters: parameters,
            success: { response in
                
                self.flickrManager.decodeJsonAsDataAndPutToImageArray(data: response.data, arrayToUpdate: ._public, callback: { (response) in
                    if response.success {
                        let response = CallStatus(success: true, error: nil)
                        callback(response)
                    } else {
                        let response = CallStatus(success: false, error: response.error)
                        callback(response)
                    }
                })
        },
            failure: { error in
                print(error)
                let response = CallStatus(success: false, error: error.localizedDescription)
                callback(response)
        }
        )
        
    }
    
    
    
}
