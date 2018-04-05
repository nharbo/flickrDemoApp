//
//  ViewController.swift
//  FlickrDemoApp
//
//  Created by Nicolai Harbo on 05/04/2018.
//  Copyright © 2018 nicoware. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
    
    let controller = LaunchController.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Start spinner
        //Check if user is logged in or not.
        
        //If logged in
        //Load public + private data/images
        //When data is fetched, continue + stop spinner.
        getPublicImagesAndContinue()
        
        //If NOT logged in:
        //Go to LoginVC
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getPublicImagesAndContinue() {
        controller.getPublicImagesAsUrl { (response) in
            //Stop spinner
            if response.success {
                //Go to tabbar
                self.performSegue(withIdentifier: "LaunchToTabbar", sender: nil)
            } else {
                //Error - show errormessage
                //Try again + start spinner
            }
        }
    }


}

