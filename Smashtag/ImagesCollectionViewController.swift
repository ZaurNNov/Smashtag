//
//  ImagesCollectionViewController.swift
//  Smashtag
//
//  Created by User on 18.10.2017.
//  Copyright © 2017 ZaurNNov. All rights reserved.
//

import UIKit
import Twitter

public struct TweetMedia: CustomStringConvertible
{
    var tweet: Twitter.Tweet
    var media: MediaItem
    
    public var description: String { return "\(tweet): \(media)" }
}

class Cache: NSCache<NSURL, NSData> {
    subscript(key: URL) -> Data? {
        get {
            return object(forKey: key as NSURL) as Data?
        }
        set {
            if let data = newValue {
                setObject(data as NSData, forKey: key as NSURL,
                          cost: data.count / 1024)
            } else {
                removeObject(forKey: key as NSURL)
            }
        }
    }
}

class ImagesCollectionViewController: UICollectionViewController,
UICollectionViewDelegateFlowLayout {
    
    var tweets: [Array<Twitter.Tweet>] = [] {
        didSet {
            images = tweets.flatMap({$0})
                .map { tweet in
                    tweet.media.map { TweetMedia(tweet: tweet, media: $0) }}
                .flatMap({$0})
        }
    }
    
    private var images = [TweetMedia]()
    private var cache = Cache()
    
    var predefinedWidth:CGFloat {return floor(((collectionView?.bounds.width)! -
        FlowLayout.minimumColumnSpacing * (FlowLayout.ColumnCount - 1.0 ) -
        FlowLayout.sectionInset.right * 2.0) / FlowLayout.ColumnCount)}
    
    var sizePredefined:CGSize {return CGSize(width: predefinedWidth,
                                             height: predefinedWidth) }
    
    private struct FlowLayout {
        static let MinImageCellWidth: CGFloat = 60
        
        static let ColumnCount:CGFloat = 3
        
        static let minimumColumnSpacing:CGFloat = 2
        static let minimumInteritemSpacing:CGFloat = 2
        static let sectionInset = UIEdgeInsets (top: 2, left: 2, bottom: 2, right: 2)
        
    }
    
    private struct variableIdentifiers {
        static let collectionImageCell = "collectionImageCell"
        //static let ShowTweet = "ShowTweet"
    }
    
    var scale: CGFloat = 1 {
        didSet {
            collectionView?.collectionViewLayout.invalidateLayout()
        }
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        collectionView?.addGestureRecognizer(UIPinchGestureRecognizer(target: self,
                                                                      action: #selector(ImagesCollectionViewController.zoom(_:))))
        installsStandardGestureForInteractiveMovement = true
        
    }
    
    @objc
    func zoom(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .changed {
            scale *= gesture.scale
            gesture.scale = 1.0
        }
    }
    
    
    private func setupLayout(){
        let layoutFlow = UICollectionViewFlowLayout()
        
        layoutFlow.minimumInteritemSpacing = FlowLayout.minimumInteritemSpacing
        layoutFlow.minimumLineSpacing = FlowLayout.minimumColumnSpacing
        layoutFlow.sectionInset = FlowLayout.sectionInset
        
        layoutFlow.itemSize = sizePredefined
        
        collectionView?.collectionViewLayout = layoutFlow
    }
    
    deinit {
        cache.removeAllObjects()
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView:
        UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: variableIdentifiers.collectionImageCell,
            for: indexPath)
        if let imageCell = cell as? ImagesCollectionViewCell {
            
            imageCell.cache = cache
            imageCell.tweetMedia = images[indexPath.row]
        }
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let ratio = CGFloat(images[indexPath.row].media.aspectRatio)
        var sizeSetting =  sizePredefined
        if let layoutFlow = collectionViewLayout as? UICollectionViewFlowLayout {
            let maxCellWidth = collectionView.bounds.size.width  -
                layoutFlow.minimumInteritemSpacing * 2.0 -
                layoutFlow.sectionInset.right * 2.0
            sizeSetting = layoutFlow.itemSize
            
            let size = CGSize(width: sizeSetting.width * scale,
                              height: sizeSetting.height * scale)
            
            let cellWidth = min (max (size.width ,
                                      FlowLayout.MinImageCellWidth),maxCellWidth)
            return (CGSize(width: cellWidth, height: cellWidth / ratio))
        }
        return CGSize(width: sizeSetting.width * scale,
                      height: sizeSetting.height * scale)
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 moveItemAt sourceIndexPath: IndexPath,
                                 to destinationIndexPath: IndexPath) {
        
        let temp = images[destinationIndexPath.row]
        images[destinationIndexPath.row] = images[sourceIndexPath.row]
        images[sourceIndexPath.row] = temp
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - Navigation

    @IBAction func backToRootView(_ sender: UIBarButtonItem) {
        _ = navigationController?.popToRootViewController(animated: true)
    }

}

