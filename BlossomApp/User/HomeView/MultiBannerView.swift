//
//  MultiBannerView.swift
//
//
//  Created by CHAKRIT PANIAM on 23/2/2564 BE.
//  Copyright © 2564 BE TOTAL ACCESS COMMUNICATION PUBLIC COMPANY LIMITED. All rights reserved.
//

import Foundation
import UIKit
import AdvancedPageControl

protocol MultiBannerViewDelegate {
    func openCampaign(promotion:Promotion)
}

enum MultiBannerViewDirectionScrollType {
    case left
    case right
}

class MultiBannerView: UIView , UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public var isAutoScroll: Bool = true
    public var delayScroll: Double = 5.0
    public var direction: MultiBannerViewDirectionScrollType = .left
    public var isLoadingCampaign: Bool = false
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: AdvancedPageControlView!
    
    
    var objects:[Promotion] = []
    var delegate: MultiBannerViewDelegate?
    
    
    // MARK: -
    // MARK: Life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Setup view from .xib file
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Setup view from .xib file
        setupView()
    }
    
    private func setupView() {
    
        if let view = Bundle(for: type(of: self)).loadNibNamed("MultiBannerView", owner: self, options: nil)?.first as? UIView {
            view.frame = bounds
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(view)
        } else {
            fatalError("""
                       Couldn't find Your Custom view for \(String(describing: self)),
                       make sure the view is invalid nib name
                       """)
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        
        pageControl.drawer = ExtendedDotDrawer( height: 8.0,
                                                width: 8.0,
                                                space: 10.0,
                                                raduis: 8.0,
                                                currentItem: 0,
                                                indicatorColor: .blossomPrimary,
                                                dotsColor: .lightGray,
                                                isBordered: false,
                                                borderColor: .white)

        let nib = UINib(nibName: "BannerViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "BannerViewCell")
        
        if isAutoScroll {
            configAutoscrollTimer()
        }
        
        
    }
    
    func reload() {
        
        pageControl.numberOfPages = objects.count
        collectionView.reloadData()
        
    }
    // MARK: -
    // MARK: draw UI
    
    
    
    // MARK: -
    // MARK: Auto Scroll
    
    func configAutoscrollTimer()
    {
        
        Timer.scheduledTimer(timeInterval: delayScroll, target: self, selector: #selector(self.scrollAutomatically), userInfo: nil, repeats: true)
         
    }
   
    @objc func scrollAutomatically(_ timer: Timer) {
        if let collection  = collectionView {
            let visibleRect = CGRect(origin: collection.contentOffset, size: collection.bounds.size)
            let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
            let visibleIndexPath = collection.indexPathForItem(at: visiblePoint)
            
            var currentRow = (visibleIndexPath?.row ?? 0) as Int
            
            if direction == .left {
                if currentRow == objects.count - 1 { currentRow = -1 }
                if currentRow < objects.count - 1 {
                    let targetIndexPath: IndexPath?
                    targetIndexPath = IndexPath.init(row: currentRow + 1, section: (visibleIndexPath?.section)!)
                    
                    collection.isPagingEnabled = false
                    collection.scrollToItem(at: targetIndexPath!, at: .centeredHorizontally, animated: true)
                    collection.isPagingEnabled = true

                }
            } else { // right
                if currentRow == 0 { currentRow = objects.count}
                if currentRow <= objects.count  {
                    let targetIndexPath: IndexPath?
                    targetIndexPath = IndexPath.init(row: currentRow - 1, section: (visibleIndexPath?.section)!)
                    
                    collection.isPagingEnabled = false
                    collection.scrollToItem(at: targetIndexPath!, at: .centeredHorizontally, animated: true)
                    collection.isPagingEnabled = true
                    
                }
            }

        }
    }
    
    
    // MARK: -
    // MARK: Scroll Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSet = scrollView.contentOffset.x
        let width = scrollView.frame.width
        
        let index = Int(round(offSet/width))
        pageControl.setPage(index)

    }
    
    
    // MARK: -
    // MARK: CollectionView DataSource & Delegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: BannerViewCell? = (collectionView.dequeueReusableCell(withReuseIdentifier: "BannerViewCell", for: indexPath) as! BannerViewCell)
        
        
        let object = objects[indexPath.row]
        cell?.drawImage(imageHilight:object.image )
        
        return cell ?? UICollectionViewCell()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
       
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let object = objects[indexPath.row]
        self.delegate?.openCampaign(promotion: object)
    }
    
    
}
