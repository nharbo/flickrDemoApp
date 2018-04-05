//
//  LaunchController.swift
//  FlickrDemoApp
//
//  Created by Nicolai Harbo on 05/04/2018.
//  Copyright © 2018 nicoware. All rights reserved.
//

import Foundation
class LaunchController {
    
    static let sharedInstance = LaunchController()
    private init() { }
    
    //MARK: - Variables
    var flickr = FlickrManager.sharedInstance
    
    //MARK: - Structs for callbacks
    struct GetPublicImagesResponse {
        var success: Bool
        var error: NSError?
    }
    
    //MARK: - Getters
    func getPublicImagesAsUrl(images: @escaping (GetPublicImagesResponse) -> Void){
        flickr.getRecentPublicImages { (response) in
            let response = GetPublicImagesResponse(success: response.success, error: response.error)
            images(response)
        }
    }
    
    //MARK: - Setters
    
    
    
}
