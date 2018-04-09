//
//  ProfileViewController.swift
//  FlickrDemoApp
//
//  Created by Nicolai Harbo on 05/04/2018.
//  Copyright © 2018 nicoware. All rights reserved.
//

import UIKit
import SDWebImage

class ProfileViewController: UIViewController {
    
    //MARK: - Variables
    let controller = ProfileController()
    
    //MARK: - IBOutlets
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    
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
        self.setUserData()
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Data functions
    func setUserData() {
        let user = controller.getCurrentUser()
        if let urlString = user.profileImageUrl {
            let url = URL(string: urlString)
            self.profileImageView.sd_setImage(with: url) { (image, error, cacheType, url) in
                print(error)
            }
        }
        self.usernameLabel.text = user.username
        self.fullNameLabel.text = user.fullname
    }
    

}
