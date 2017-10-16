//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by ZaurNNov on 15.10.2017.
//  Copyright © 2017 ZaurNNov. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell {

    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    @IBOutlet weak var tweetUserLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    
    var tweet: Twitter.Tweet? {didSet {updateUI()}}
    
    struct differentColorMentiones {
        static let hashtagNowPurple = UIColor.purple
        static let urlNowBlue = UIColor.blue
        static let userNamesNowOrange = UIColor.orange
    }
    
    private func setTextLabel(_ tweet: Twitter.Tweet?) -> NSMutableAttributedString {
        guard let tweet = tweet else {return NSMutableAttributedString(string: "")}
        var tweetText: String = tweet.text
        
        for _ in tweet.media {tweetText += " 📷"}
        let attributetText = NSMutableAttributedString(string: tweetText)
        
        attributetText.setMentionsColor(tweet.hashtags, color: differentColorMentiones.hashtagNowPurple)
        attributetText.setMentionsColor(tweet.urls, color: differentColorMentiones.urlNowBlue)
        attributetText.setMentionsColor(tweet.userMentions, color: differentColorMentiones.urlNowBlue)
        
        return attributetText
    }
    
    private func updateUI() {
        tweetUserLabel?.text = tweet?.user.description
        
        //add color attributes
        tweetTextLabel?.attributedText = setTextLabel(tweet)
        
        if let profileImageURL = tweet?.user.profileImageURL {
            //Fix this main thread
            if let imageData = try? Data(contentsOf: profileImageURL) {
                tweetProfileImageView?.image = UIImage(data: imageData)
            }
        } else {
            tweetProfileImageView?.image = nil
        }
        
        if let created = tweet?.created {
            let formatter = DateFormatter()
            if Date().timeIntervalSince(created) > 24*60*60 {
                formatter.dateStyle = .short
            } else {
                formatter.dateStyle = .medium
            }
            
            tweetCreatedLabel?.text = formatter.string(from: created)
        } else {
            tweetCreatedLabel?.text = nil
        }
    }
    
}

private extension NSMutableAttributedString {
    func setMentionsColor(_ mention: [Mention], color: UIColor) {
        for mention in mention {
            addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: mention.nsrange)
        }
    }
}
