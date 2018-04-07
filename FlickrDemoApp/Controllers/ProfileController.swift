//
//  ProfileController.swift
//  FlickrDemoApp
//
//  Created by Nicolai Harbo on 07/04/2018.
//  Copyright © 2018 nicoware. All rights reserved.
//

import Foundation

class ProfileController {
    
    //    let flickr = FlickrManager.sharedInstance
    let realm = RealmManager.sharedInstance
    
    //MARK: - Structs for callbacks
    struct CallbackStatus {
        var success: Bool
        var error: NSError?
    }
    
    //MARK: - Setters
    func removeCurrentUser(userId: String, callback: @escaping (CallbackStatus) -> Void) {
        realm.removeCurrentUser(userId: userId) { (response) in
            let response = CallbackStatus(success: response.success, error: response.error)
            callback(response)
        }
    }
    
    //MARK: - Getters
    func getCurrentUser() -> RealmUser {
        return realm.getCurrentUser()!
    }

    
    
}
