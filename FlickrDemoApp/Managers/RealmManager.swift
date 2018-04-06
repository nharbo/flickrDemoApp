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
    
    //MARK: - Global Variables
    let realm = try! Realm()
    
    //MARK: - Getters
    func getCurrentUser() -> RealmUser? {
        
        let user = realm.objects(RealmCurrentUser.self)
        if user.count < 1 {
            print("no user in realm - returning nil")
            return nil
        } else {
            print("got current user in realm")
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
            print("Current user SET in Realm! (realm manager)")
        }
    }
    
    func setUserData(user: User) {
            
        let userToTest: RealmUser? = self.getUser(userId: user.user_nsid!)
        var userInRealm: RealmUser?
        
        if userToTest == nil {
            // No user in Realm - creating one!
            print("--- No user in Realm - creating one!... ")
            userInRealm = RealmUser()
            if let userId = user.user_nsid { userInRealm!.user_nsid = userId }
        } else {
            // User already in Realm - updating!
            print("--- User already in Realm - updating!... ")
            userInRealm = userToTest
        }
        
        try! self.realm.write {
            print("--- syncronizing realm user... ")

            //User info
            if let fullName = user.fullname { userInRealm!.fullname = fullName }
            if let profileImageUrl = user.profileImageUrl { userInRealm!.profileImageUrl = profileImageUrl }
            if let username = user.username { userInRealm!.username = username }
            
            self.realm.add(userInRealm!, update: true)
            try! self.realm.commitWrite()
            print("--- DONE syncronizing realm user... ")
        }
    }
    
    //MARK: - DELETE
//    func removeCurrentUser(objectId: String) {
//        print("in remove user")
//        if let userToRemove = realm.objectForPrimaryKey(RealmCurrentUser.self, key: objectId) {
//            print("User to remove: \(userToRemove)")
//            try! realm.write {
//                realm.delete(userToRemove)
//                print("Current user REMOVEd from Realm! (realm manager)")
//            }
//        } else {
//            print("could not remove user")
//        }
//    }
    
    
}
