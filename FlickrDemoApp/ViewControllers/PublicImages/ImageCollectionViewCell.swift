//
//  ImageCollectionViewCell.swift
//  FlickrDemoApp
//
//  Created by Nicolai Harbo on 11/04/2018.
//  Copyright © 2018 nicoware. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet weak var collImageView: UIImageView!
    
    //MARK: - Variables
    var singleImage: Image? {
        didSet {
            update()
        }
    }
    
    
    //MARK: - Functions
    func update() {
        if let imageUrl = singleImage?.imageUrl {
            let url = URL(string: imageUrl)
            self.collImageView.sd_setImage(with: url) { (image, error, cacheType, url) in
            }
        } else {
            //TODO: Set placeholder
        }
    }
    
}
