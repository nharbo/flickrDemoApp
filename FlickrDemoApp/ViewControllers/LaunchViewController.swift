//
//  ViewController.swift
//  FlickrDemoApp
//
//  Created by Nicolai Harbo on 05/04/2018.
//  Copyright © 2018 nicoware. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
    
    //MARK: - Constants
    let controller = LaunchController()

    //MARK: - Variables
    var timer: Timer?
    var attempts = 1
    var waitFor = 4.0
    
    //MARK: - IBOutlets
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.activityIndicatorView.startAnimating()

        if let _ = controller.getCurrentUser() {
            getDataAndContinue()
        } else {
            //Wait 3 seconds before continueing
            timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(segueWith(timer:)),userInfo:nil, repeats: false)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Timed functions
    @objc func segueWith(timer: Timer!) {
        self.performSegue(withIdentifier: "LaunchToLogin", sender: nil)
    }
    
    //MARK: - Data functions
    func getDataAndContinue() {
        controller.getPublicImagesAsUrl { (response) in
            if response.success {
                //Got public images - get users own images
                self.controller.getOwnImagesAsUrl(callback: { (response) in
                    if response.success {
                        //Update userinformations
                        self.controller.getUserInfo(userId: self.controller.getCurrentUser()!.user_nsid!, callback: { (response) in
                            if response.success {
                                self.activityIndicatorView.stopAnimating()
                                //Updated userinformations, and got all images and userinfo - go to tabbar!
                                self.performSegue(withIdentifier: "LaunchToTabbar", sender: nil)
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
            self.activityIndicatorView.stopAnimating()
        } else {
            InfoMessage.presentInfoMessageWithTitle(title: error, ofType: .Alert)
            timer = Timer.scheduledTimer(timeInterval: waitFor, target: self, selector: #selector(eventWith(timer:)),userInfo:nil, repeats: false)
        }
    }
    
    @objc func eventWith(timer: Timer!) {
        attempts = attempts + 1
        waitFor = Double(attempts * 2)
        self.getDataAndContinue()
    }


}

