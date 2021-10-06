//
//  GaleryViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 6/10/2564 BE.
//

import UIKit
import SwiftPhotoGallery

class GaleryViewController: UIViewController, SwiftPhotoGalleryDataSource, SwiftPhotoGalleryDelegate {

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gallery = SwiftPhotoGallery(delegate: self, dataSource: self)
        gallery.backgroundColor = UIColor.black
        gallery.pageIndicatorTintColor = UIColor.gray.withAlphaComponent(0.5)
        gallery.currentPageIndicatorTintColor = UIColor.white
        gallery.hidePageControl = false
    }
    
    func numberOfImagesInGallery(gallery: SwiftPhotoGallery) -> Int {
        return 0
    }
    
    func imageInGallery(gallery: SwiftPhotoGallery, forIndex: Int) -> UIImage? {
        return UIImage(named: "")
    }
    
    // MARK: SwiftPhotoGalleryDelegate Methods
    
    func galleryDidTapToClose(gallery: SwiftPhotoGallery) {
        dismiss(animated: true, completion: nil)
    }
}
