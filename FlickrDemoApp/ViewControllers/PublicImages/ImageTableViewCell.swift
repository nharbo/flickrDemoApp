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
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
