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
        //Tjek om brugeren er logget ind eller ej
        //Hvis logget ind:
        //Load public data
        
        //Gå videre, når data er hentet + stop spinner
        getPublicImagesAndContinue()
        //Hvis ikke logget ind:
        //Gå til loginVC
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getPublicImagesAndContinue() {
        controller.getPublicImagesAsUrl { (response) in
            //Stop spinner
            if response.error == nil {
                print(response.images as! [String])
                //Go to tabbar
                self.performSegue(withIdentifier: "LaunchToTabbar", sender: nil)
            } else {
                //Error - show errormessage
                //Try again + start spinner
            }
        }
    }


}

