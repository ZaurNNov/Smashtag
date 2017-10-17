//
//  SmashTweetTableViewController.swift
//  Smashtag
//
//  Created by User on 17.10.2017.
//  Copyright © 2017 ZaurNNov. All rights reserved.
//

import UIKit
import Twitter
import CoreData

class SmashTweetTableViewController: TweetTableViewController {

    override func insertTweets(_ newTweets: [Twitter.Tweet]){
        super.insertTweets(newTweets)
        updateDatabase(with: newTweets)
        
    }
    
    private func updateDatabase(with tweets: [Twitter.Tweet]) {
        
    }
}
