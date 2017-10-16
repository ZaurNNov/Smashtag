//
//  ImageTableViewCell.swift
//  Smashtag
//
//  Created by ZaurNNov on 16.10.2017.
//  Copyright © 2017 ZaurNNov. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tweetImage: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var imageUrl: URL? {didSet {updateUI()}}
    
    private func updateUI()
    {
        if let url = imageUrl {
            spinner?.startAnimating()
            
            DispatchQueue.global(qos: .userInitiated).async {
                let contentsOfURL = try? Data(contentsOf: url)
                
                DispatchQueue.main.async {
                    if url == self.imageUrl {
                        if let imageData = contentsOfURL {
                            self.tweetImage?.image = UIImage(data: imageData)
                        }
                        self.spinner?.stopAnimating()
                    }
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
