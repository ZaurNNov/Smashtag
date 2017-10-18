//
//  ImagesCollectionViewCell.swift
//  Smashtag
//
//  Created by User on 18.10.2017.
//  Copyright © 2017 ZaurNNov. All rights reserved.
//

import UIKit
import Twitter

class ImagesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var cache: Cache?
    
    var tweetMedia: TweetMedia? {
        didSet {
            imageView.image = nil
            guard let url = tweetMedia?.media.url else {  return }
            spinner?.startAnimating()
            
            if let imageData = cache?[url] {    // cached?
                
                imageView.image = UIImage(data: imageData)
                spinner?.stopAnimating()
                return
            }
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                if url == self?.tweetMedia?.media.url,
                    let imageData = try? Data(contentsOf: url) {
                    
                    DispatchQueue.main.async {
                        self?.imageView.image = UIImage(data: imageData)
                        
                        self?.cache?[url] = imageData
                        self?.spinner.stopAnimating()
                    }
                }
            }
        }
    }
}



















