//
//  LaunchController.swift
//  FlickrDemoApp
//
//  Created by Nicolai Harbo on 05/04/2018.
//  Copyright © 2018 nicoware. All rights reserved.
//

import Foundation
class LaunchController {
    
    //MARK: - Variables
    let flickr = FlickrManager.sharedInstance
    let realm = RealmManager.sharedInstance
    
    //MARK: - Structs for callbacks
    struct ApiCallStatus {
        var success: Bool
        var error: NSError?
    }
    
    //MARK: - Getters
    func getPublicImagesAsUrl(callback: @escaping (ApiCallStatus) -> Void){
        flickr.getRecentPublicImages { (response) in
            let response = ApiCallStatus(success: response.success, error: response.error)
            callback(response)
        }
    }
    
    func getOwnImagesAsUrl(callback: @escaping (ApiCallStatus) -> Void){
        flickr.getOwnImages { (response) in
            let response = ApiCallStatus(success: response.success, error: response.error)
            callback(response)
        }
    }

    func getCurrentUser() -> RealmUser? {
        return realm.getCurrentUser()
    }
    
    //MARK: - Setters
    
    
    
}
