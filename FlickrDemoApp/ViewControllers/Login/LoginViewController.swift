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
    
    //MARK: - Constants
    let controller = LoginController()
    
    //MARK: - Variables
    var timer: Timer?
    var attempts = 1
    var waitFor = 4.0
    var user: User?
    var loggedIn = false
    
    //MARK: - IBOutlets
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var tintView: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - IBActions
    @IBAction func loginButtonTapped(_ sender: Any) {
        self.showSpinnerView()
        // Authorize with Flickr via OAuth
        let oauth = controller.getOauth()
        oauth.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: oauth)
        let _ = oauth.authorize(
                withCallbackURL: URL(string: "FlickrDemoApp://oauth-callback/flickr")!,
                success: { credential, response, parameters in
                    self.showSpinnerView()
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
                    self.user = user
                    self.getDataAndContinue(user: user)
            },
                failure: { error in
                    self.hideSpinnerView()
                    InfoMessage.presentInfoMessageWithTitle(title: error.localizedDescription, ofType: .Alert)
            }
        )
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUISetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = controller.getCurrentUser() {
            showSpinnerView()
        } else {
            hideSpinnerView()
        }
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        if let _ = controller.getCurrentUser() {
//            showSpinnerView()
//        } else {
//            hideSpinnerView()
//        }
//    }

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
                                self.activityIndicator.stopAnimating()
                                //Take user to tabbar
                                self.performSegue(withIdentifier: "LoginToTabbar", sender: nil)
                            } else {
                                self.presentErrorMessageAndRetry(error: response.error!)
                            }
                        })
                    } else {
                        self.presentErrorMessageAndRetry(error: response.error!)
                    }
                })
            } else {
                self.presentErrorMessageAndRetry(error: response.error!)
            }
        }
    }
    
    //MARK: - Errorhandling functions
    func presentErrorMessageAndRetry(error: String) {
        if waitFor > 10.0 {
            InfoMessage.presentInfoMessageWithTitle(title: "Couldn't connect to the server - please try again later", ofType: .Alert)
            self.activityIndicator.stopAnimating()
        } else {
            InfoMessage.presentInfoMessageWithTitle(title: error, ofType: .Alert)
            timer = Timer.scheduledTimer(timeInterval: waitFor, target: self, selector: #selector(eventWith(timer:)),userInfo:nil, repeats: false)
        }
    }
    
    @objc func eventWith(timer: Timer!) {
        attempts = attempts + 1
        waitFor = Double(attempts * 2)
        if let userToGetDataFrom = self.user {
            self.getDataAndContinue(user: userToGetDataFrom)
        } else {
            InfoMessage.presentInfoMessageWithTitle(title: "Something went wrong - please try again later", ofType: .Alert)
        }
        
    }
    
    //MARK: - Helperfunctions
    func initialUISetup() {
        //Loading views setup
        hideSpinnerView()
        
        //Login button setup
        loginButton.layer.cornerRadius = loginButton.frame.height / 2
        loginButton.layer.shadowColor = UIColor.gray.cgColor
        loginButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        loginButton.layer.shadowOpacity = 0.5
        loginButton.layer.shadowRadius = 1.8
        loginButton.layer.masksToBounds = false
    }
    
    func showSpinnerView() {
        self.tintView.isHidden = false
        self.loadingView.isHidden = false
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
    }
    
    func hideSpinnerView(){
        self.tintView.isHidden = true
        self.loadingView.isHidden = true
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
    }
    
}

