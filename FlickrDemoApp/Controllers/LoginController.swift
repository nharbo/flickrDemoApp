//
//  LoginController.swift
//  FlickrDemoApp
//
//  Created by Nicolai Harbo on 05/04/2018.
//  Copyright © 2018 nicoware. All rights reserved.
//

import Foundation

class LoginController {
    
//    let flickr = FlickrManager.sharedInstance
    let realm = RealmManager.sharedInstance
    
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
    
    
}
