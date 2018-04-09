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
        // Authorize with Flickr via OAuth
        let oauth = controller.getOauth()
        oauth.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: oauth)
        let _ = oauth.authorize(
                withCallbackURL: URL(string: "FlickrDemoApp://oauth-callback/flickr")!,
                success: { credential, response, parameters in
                    
                    let user = User()
                    if let userId = parameters["user_nsid"] as? String {
                        var idToSave = userId.removingPercentEncoding
                        user.user_nsid = idToSave
                        self.controller.setCurrentUser(userId: idToSave!)
                    }
                    if let fullname = parameters["fullname"] as? String { user.fullname = fullname.removingPercentEncoding }
                    if let username = parameters["username"] as? String { user.username = username.removingPercentEncoding }
                    if let token = credential.oauthToken as? String { user.token = token }
                    if let secret = credential.oauthTokenSecret as? String { user.secret = secret }
                    self.controller.setUserData(user: user)
                    
                    self.getDataAndContinue(user: user)
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
    func getDataAndContinue(user: User) {
        controller.getPublicImagesAsUrl { (response) in
            //Stop spinner
            if response.success {
                //Got public images - get users own images
                self.controller.getOwnImagesAsUrl(callback: { (response) in
                    if response.success {
                        //Got own images - update userinformations
                        self.controller.getUserInfo(userId: user.user_nsid!, callback: { (response) in
                            if response.success {
                                //Take user to tabbar
                                self.performSegue(withIdentifier: "LoginToTabbar", sender: nil)
                            } else {
                                //TODO: Handle error
                            }
                        })
                    } else {
                        //TODO: Handle error
                    }
                })
            } else {
                //TODO: Error - show errormessage
            }
        }
    }
    
    
}

