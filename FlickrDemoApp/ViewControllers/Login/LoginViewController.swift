//
//  LoginViewController.swift
//  FlickrDemoApp
//
//  Created by Nicolai Harbo on 05/04/2018.
//  Copyright © 2018 nicoware. All rights reserved.
//

import UIKit
import SafariServices
import OAuthSwift

class LoginViewController: UIViewController {
    
    //MARK: - Variables
    let controller = LoginController()
    let oauthswift = OAuth1Swift(
        consumerKey:    "2c19e234e56cdb527c82cce28f0b41dc",
        consumerSecret: "6d5ab2dd04827bea",
        requestTokenUrl: "https://www.flickr.com/services/oauth/request_token",
        authorizeUrl:    "https://www.flickr.com/services/oauth/authorize",
        accessTokenUrl:  "https://www.flickr.com/services/oauth/access_token"
    )
    
    //MARK: - IBOutlets
    @IBOutlet weak var loginButton: UIButton!
    
    //MARK: - IBActions
    @IBAction func loginButtonTapped(_ sender: Any) {
        // authorize
        oauthswift.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: oauthswift)
        let _ = self.oauthswift.authorize(
                withCallbackURL: URL(string: "FlickrDemoApp://oauth-callback/flickr")!,
                success: { credential, response, parameters in
                    print(credential.oauthToken)
                    print(credential.oauthTokenSecret)
                    if let userId = parameters["user_nsid"] as? String {
                        self.controller.setCurrentUser(userId: userId)
                        let user = User()
                        if let fullname = parameters["fullname"] as? String { user.fullname = fullname }
                        if let username = parameters["username"] as? String { user.username = username }
                        user.user_nsid = userId
                        self.controller.setUserData(user: user)
                    }
            },
                failure: { error in
                    print(error.localizedDescription)
            }
        )
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}

