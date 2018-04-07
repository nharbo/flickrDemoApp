//
//  ProfileViewController.swift
//  FlickrDemoApp
//
//  Created by Nicolai Harbo on 05/04/2018.
//  Copyright © 2018 nicoware. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    //MARK: - Variables
    let controller = ProfileController()
    
    //MARK: - IBOutlets
    @IBOutlet weak var logOutButton: UIButton!
    
    //MARK: - IBActions
    @IBAction func logOutButtonTapped(_ sender: Any) {
        controller.removeCurrentUser(userId: controller.getCurrentUser().user_nsid!) { (response) in
            if response.success {
                //Take user to loginscreen
                self.performSegue(withIdentifier: "ProfileToLogin", sender: nil)
            } else {
                //TODO: Handle error
            }
        }
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
