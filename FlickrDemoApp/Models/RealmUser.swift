//
//  RealmUser.swift
//  FlickrDemoApp
//
//  Created by Nicolai Harbo on 06/04/2018.
//  Copyright © 2018 nicoware. All rights reserved.
//

import Foundation
import RealmSwift

class RealmUser: Object {

    @objc dynamic var fullname: String?
    @objc dynamic var username: String?
    @objc dynamic var profileImageUrl: String?
    @objc dynamic var user_nsid: String?

    override class func primaryKey() -> String? {
        return "user_nsid"
    }
}
