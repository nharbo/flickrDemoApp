//
//  ImageTableViewCell.swift
//  FlickrDemoApp
//
//  Created by Nicolai Harbo on 05/04/2018.
//  Copyright © 2018 nicoware. All rights reserved.
//

import UIKit
import SDWebImage

class ImageTableViewCell: UITableViewCell {
    
    var singleImage: Image? {
        didSet {
            update()
        }
    }
    
    @IBOutlet weak var flickerImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        //Background view setup
        backgroundImageView.layer.shadowColor = UIColor.black.cgColor
        backgroundImageView.layer.shadowOpacity = 1
        backgroundImageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        backgroundImageView.layer.shadowRadius = 4
        backgroundImageView.layer.cornerRadius = 4
        //ImageView setup
        flickerImageView.layer.cornerRadius = 4
        flickerImageView.layer.borderColor = UIColor.black.cgColor
        flickerImageView.layer.borderWidth = 0.1
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func update() {
        if let imageUrl = singleImage?.imageUrl {
            let url = URL(string: imageUrl)
            self.flickerImageView.sd_setImage(with: url) { (image, error, cacheType, url) in
            }
        } else {
            //TODO: Set placeholder
        }
    }
    
    func resetCell() {
        self.flickerImageView.image = nil
    }

}
