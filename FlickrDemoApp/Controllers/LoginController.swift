//
//  LoginController.swift
//  FlickrDemoApp
//
//  Created by Nicolai Harbo on 05/04/2018.
//  Copyright © 2018 nicoware. All rights reserved.
//

import Foundation
import OAuthSwift

class LoginController {
    
    let flickr = FlickrManager.sharedInstance
    let realm = RealmManager.sharedInstance
    
    //MARK: - Structs for callbacks
    struct ApiCallStatus {
        var success: Bool
        var error: NSError?
    }
    
    //MARK: - Setters
    func setCurrentUser(userId: String) {
        realm.setCurrentUser(userId: userId)
    }
    
    func setUserData(user: User) {
        realm.setUserData(user: user)
    }
    
    //MARK - Getters
    func getCurrentUser() -> RealmUser? {
        return realm.getCurrentUser()
    }
    
    func getPublicImagesAsUrl(callback: @escaping (ApiCallStatus) -> Void){
        flickr.getRecentPublicImages { (response) in
            let response = ApiCallStatus(success: response.success, error: response.error)
            callback(response)
        }
    }
    
    func getOauth() -> OAuth1Swift {
        return flickr.getOauth()
    }
    
    func getFlickrApiKey() -> String {
        return flickr.getApiKey()
    }
    
    
}
