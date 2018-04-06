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
            getPublicImagesAndContinue()
        } else {
            //If NOT logged in, go to LoginVC
            self.performSegue(withIdentifier: "LaunchToLogin", sender: nil)
        }
        
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

