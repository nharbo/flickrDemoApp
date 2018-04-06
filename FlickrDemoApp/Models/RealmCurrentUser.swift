//
//  RealmCurrentUser.swift
//  FlickrDemoApp
//
//  Created by Nicolai Harbo on 06/04/2018.
//  Copyright © 2018 nicoware. All rights reserved.
//

import Foundation
import RealmSwift

class RealmCurrentUser: Object {
    
    @objc dynamic var userId: String?
    
    override class func primaryKey() -> String? {
        return "userId"
    }
    
}
