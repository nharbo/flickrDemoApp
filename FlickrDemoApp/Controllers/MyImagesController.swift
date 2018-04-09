//
//  MyImagesController.swift
//  FlickrDemoApp
//
//  Created by Nicolai Harbo on 08/04/2018.
//  Copyright © 2018 nicoware. All rights reserved.
//

import Foundation

class MyImagesController {
    
    //MARK: - Variables
    var flickr = FlickrManager.sharedInstance
    
    //MARK: - Structs for callbacks
    struct GetOwnImagesResponse {
        var success: Bool
        var error: String?
    }
    
    //MARK: - Getters
    func getOwnImages() -> [Image] {
        return flickr.getOwnImages()
    }
    
    func getOwnImagesAsUrl(images: @escaping (GetOwnImagesResponse) -> Void){
        flickr.getOwnImages { (response) in
            let response = GetOwnImagesResponse(success: response.success, error: response.error)
            images(response)
        }
    }
    
    //MARK: - Setters
    
    
    
}
