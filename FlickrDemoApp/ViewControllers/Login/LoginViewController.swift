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
    //TODO: get token and secret from plist
    let controller = LoginController()
    
    //MARK: - IBOutlets
    @IBOutlet weak var loginButton: UIButton!
    
    //MARK: - IBActions
    @IBAction func loginButtonTapped(_ sender: Any) {
        let oauth = controller.getOauth()
        // authorize
        oauth.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: oauth)
        let _ = oauth.authorize(
                withCallbackURL: URL(string: "FlickrDemoApp://oauth-callback/flickr")!,
                success: { credential, response, parameters in
                    
                    
                    
                    let user = User()
                    if let userId = parameters["user_nsid"] as? String {
                        user.user_nsid = userId
                        self.controller.setCurrentUser(userId: userId)
                    }
                    if let fullname = parameters["fullname"] as? String { user.fullname = fullname }
                    if let username = parameters["username"] as? String { user.username = username }
                    if let token = credential.oauthToken as? String { user.token = token }
                    if let secret = credential.oauthTokenSecret as? String { user.secret = secret }
                    self.controller.setUserData(user: user)
                    
//                    //Get Oauth signature
//                    let signatureUrlString = "https://www.flickr.com/services/oauth/request_token?oauth_nonce=89601180&oauth_timestamp=1305583298&oauth_consumer_key=" + self.controller.getFlickrApiKey() + "&oauth_signature_method=HMAC-SHA1&oauth_version=1.0&oauth_callback=http%3A%2F%2Fwww.example.com"
//                    let signatureUrl = URL(string: signatureUrlString)!
//
//                    //Save signature in NSUserDefaults
//                    UserDefaults.standard.set(credential.signature(method: .GET, url: signatureUrl, parameters: [:]), forKey: "oauthSignature")
                    
                    self.getDataAndContinue()
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
    
    //MARK: - Data Functions
    func getDataAndContinue() {
        controller.getPublicImagesAsUrl { (response) in
            //Stop spinner
            if response.success {
                //Got public images
                //Get users own images
                //Update userinformations
                
                //Take user to tabbar
                self.performSegue(withIdentifier: "LoginToTabbar", sender: nil)
            } else {
                //TODO: Error - show errormessage
                //Try again + start spinner
            }
        }
    }
    
    
}

