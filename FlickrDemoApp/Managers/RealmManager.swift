//
//  RealmManager.swift
//  FlickrDemoApp
//
//  Created by Nicolai Harbo on 06/04/2018.
//  Copyright © 2018 nicoware. All rights reserved.
//

import Foundation
import RealmSwift

class RealmManager {
    
    static let sharedInstance = RealmManager()
    private init() { }
    
    //MARK: - Constants
    let realm = try! Realm()
    
    //MARK: - Structs for callbacks
    struct CallbackStatus {
        var success: Bool
        var error: String?
    }
    
    //MARK: - Getters
    func getCurrentUser() -> RealmUser? {
        let user = realm.objects(RealmCurrentUser.self)
        if user.count < 1 {
            return nil
        } else {
            let currentUser = self.realm.object(ofType: RealmUser.self, forPrimaryKey: user[0].userId)
            return currentUser!
        }
    }
    
    func getUser(userId: String) -> RealmUser? {
        return realm.object(ofType: RealmUser.self, forPrimaryKey: userId)
    }
    
    //MARK: - Setters
    func setCurrentUser(userId: String) {
        let currentUser = RealmCurrentUser()
        currentUser.userId = userId
        
        try! realm.write {
            realm.add(currentUser)
        }
    }
    
    //Sets userdata in Realm for new users, and update userdata for existing users
    func setUserData(user: User) {
            
        let userToTest: RealmUser? = self.getUser(userId: user.user_nsid!)
        var userInRealm: RealmUser?
        
        if userToTest == nil {
            // No user in Realm - creating one!
            userInRealm = RealmUser()
            if let userId = user.user_nsid { userInRealm!.user_nsid = userId }
        } else {
            // User already in Realm - updating!
            userInRealm = userToTest
        }
        
        try! self.realm.write {
            //User info
            if let fullName = user.fullname { userInRealm!.fullname = fullName }
            if let profileImageUrl = user.profileImageUrl { userInRealm!.profileImageUrl = profileImageUrl }
            if let username = user.username { userInRealm!.username = username }
            if let token = user.token { userInRealm!.token = token }
            if let secret = user.secret { userInRealm!.tokenSecret = secret }
            
            self.realm.add(userInRealm!, update: true)
            try! self.realm.commitWrite()
        }
    }
    
    //MARK: - DELETE
    func removeCurrentUser(userId: String, callback: @escaping (CallbackStatus) -> Void) {
        if let userToRemove = realm.object(ofType: RealmCurrentUser.self, forPrimaryKey: userId) {
            try! realm.write {
                realm.delete(userToRemove)
                let response = CallbackStatus(success: true, error: nil)
                callback(response)
            }
        } else {
            let response = CallbackStatus(success: false, error: "Could not logout user")
            callback(response)
        }
    }
    
    
}
