//
//  ViewController.swift
//  FlickrDemoApp
//
//  Created by Nicolai Harbo on 05/04/2018.
//  Copyright © 2018 nicoware. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
    
    let controller = LaunchController()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Start spinner
        //Check if user is logged in or not.
        if let _ = controller.getCurrentUser() {
            //If logged in - load public + private data/images
            //When data is fetched, continue + stop spinner.
            getDataAndContinue()
        } else {
            //If NOT logged in, go to LoginVC
            self.performSegue(withIdentifier: "LaunchToLogin", sender: nil)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Data functions
    func getDataAndContinue() {
        
//        self.performSegue(withIdentifier: "LaunchToTabbar", sender: nil)
        
//        self.controller.getOwnImagesAsUrl(callback: { (response) in
//            if response.success {
//                //Update userinformations
//                //Got all images - go to tabbar!
//                self.performSegue(withIdentifier: "LaunchToTabbar", sender: nil)
//            } else {
//                //TODO: Error, could not get users photos. show errormessage!
//            }
//        })
        
        
        controller.getPublicImagesAsUrl { (response) in
            //Stop spinner
            if response.success {
//                self.performSegue(withIdentifier: "LaunchToTabbar", sender: nil)
                //Got public images - get users own images
                self.controller.getOwnImagesAsUrl(callback: { (response) in
                    if response.success {
                        //Update userinformations
                        //Got all images - go to tabbar!
                        self.performSegue(withIdentifier: "LaunchToTabbar", sender: nil)
                    } else {
                        //TODO: Error, could not get users photos. show errormessage!
                    }
                })
            } else {
                //TODO: Error - show errormessage - could not get public images
            }
        }
    }


}

