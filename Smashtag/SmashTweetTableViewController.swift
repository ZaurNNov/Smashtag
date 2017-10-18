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

    //coreData container
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    override func insertTweets(_ newTweets: [Twitter.Tweet]){
        super.insertTweets(newTweets)
        updateDatabase(with: newTweets)
        
    }
    
    private func updateDatabase(with tweets: [Twitter.Tweet]) {
        print("Starting database load")
        container?.performBackgroundTask{ [weak self] context in
            for tweeterInfo in tweets {
                //add tweet
                _ = try? Tweet.findOrCreateTweet(matching: tweeterInfo, in: context)
                
            }
            try? context.save()
            print("done loading database")
            self?.printsDatabaseStatistics()
        }
        
    }
    
    private func printsDatabaseStatistics(){
        if let context = container?.viewContext {
            context.perform {
                if Thread.isMainThread {
                    print("is Main Thread!")
                } else {
                    print("is Not Main Thread!")
                }
                
                let request: NSFetchRequest<Tweet> = Tweet.fetchRequest()
                if let tweetCount = (try? context.fetch(request))?.count {
                    print("\(tweetCount) tweets")
                }
                
                if let tweeterCount = try? context.count(for: TwitterUser.fetchRequest()) {
                    print("\(tweeterCount) Twitter users")
                }
            }
        }
    }
    
    private struct variableIdentifiers {
        //for segue
        static let ShowMentions = "ShowMentions"
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let id = segue.identifier {
            if id == variableIdentifiers.ShowMentions,
                let mtvc = segue.destination as? MentionsTableViewController,
                let tweetCell = sender as? TweetTableViewCell {
                mtvc.tweet = tweetCell.tweet
            }
        }
    }
}
