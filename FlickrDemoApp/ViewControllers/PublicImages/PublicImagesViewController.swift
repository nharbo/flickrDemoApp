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
import TRMosaicLayout

class PublicImagesViewController: UIViewController {
    
    //MARK: - Constants
    let refreshControl = UIRefreshControl()
    
    //MARK: - Variables
    var controller = PublicImagesController()
    var images = [Image]()
    
    //MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //CollectionView setup
        refreshControl.addTarget(self, action: #selector(reloadData(_:)), for: .valueChanged)
        collectionView.backgroundView = refreshControl
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        let mosaicLayout = TRMosaicLayout()
        self.collectionView?.collectionViewLayout = mosaicLayout
        mosaicLayout.delegate = self
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
                self.collectionView.reloadData()
            } else {
                InfoMessage.presentInfoMessageWithTitle(title: response.error!, ofType: .Alert)
            }
        }
    }

}

//MARK: - Delegates
extension PublicImagesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
        
        cell.singleImage = self.images[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //Show image in full size when tapping
        let cell = collectionView.cellForItem(at: indexPath) as! ImageCollectionViewCell

        let configuration = ImageViewerConfiguration { config in
            config.imageView = cell.collImageView
        }

        present(ImageViewerController(configuration: configuration), animated: true)
    }
  
}


extension PublicImagesViewController: TRMosaicLayoutDelegate {
    
    func collectionView(_ collectionView:UICollectionView, mosaicCellSizeTypeAtIndexPath indexPath:IndexPath) -> TRMosaicCellType {
        // every third cell as .big
        return indexPath.item % 3 == 0 ? TRMosaicCellType.big : TRMosaicCellType.small
    }
    
    func collectionView(_ collectionView:UICollectionView, layout collectionViewLayout: TRMosaicLayout, insetAtSection:Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
    }
    
    func heightForSmallMosaicCell() -> CGFloat {
        return 150
    }
}


