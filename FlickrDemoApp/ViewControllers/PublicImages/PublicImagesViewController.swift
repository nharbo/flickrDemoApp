//
//  PublicImagesViewController.swift
//  FlickrDemoApp
//
//  Created by Nicolai Harbo on 05/04/2018.
//  Copyright © 2018 nicoware. All rights reserved.
//

import UIKit
import SDWebImage
import SimpleImageViewer

class PublicImagesViewController: UIViewController {
    
    //MARK: - Constants
    let refreshControl = UIRefreshControl()
    
    //MARK: - Variables
    var controller = PublicImagesController()
    var images = [Image]()
    
    //MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Tableview setup
        tableView.delegate = self
        tableView.dataSource = self
        refreshControl.addTarget(self, action: #selector(reloadData(_:)), for: .valueChanged)
        tableView.backgroundView = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.images = controller.getPublicImages()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Functions
    @objc private func reloadData(_ sender: Any) {
        controller.getPublicImagesAsUrl { (response) in
            //Stop spinner
            if response.success {
                self.images = self.controller.getPublicImages()
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
            } else {
                InfoMessage.presentInfoMessageWithTitle(title: response.error!, ofType: .Alert)
            }
        }
    }

}

//MARK: - UITableView delegates
extension PublicImagesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controller.getPublicImages().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageTableViewCell", for: indexPath) as! ImageTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.singleImage = self.images[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        let cellHeight = screenHeight / 3
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Show image in full size when tapping
        let cell = tableView.cellForRow(at: indexPath) as! ImageTableViewCell
        
        let configuration = ImageViewerConfiguration { config in
            config.imageView = cell.flickerImageView
        }
        
        present(ImageViewerController(configuration: configuration), animated: true)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ImageTableViewCell", for: indexPath) as? ImageTableViewCell {
            cell.resetCell()
        }
    }
    
}


