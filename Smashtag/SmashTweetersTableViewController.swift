//
//  SmashTweetersTableViewController.swift
//  Smashtag
//
//  Created by User on 17.10.2017.
//  Copyright © 2017 ZaurNNov. All rights reserved.
//

import UIKit
import CoreData

class SmashTweetersTableViewController: FetchedResultsTableViewController {
    
    private struct variableIdentifiers {
        //for cell
        static let TwitterUserCell = "TwitterUserCell"
    }
    
    var mentions: String? {didSet{UpdateUI()}}
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer {didSet{UpdateUI()}}
    
    var fetchedResultsController: NSFetchedResultsController<TwitterUser>?

    private func UpdateUI() {
        if let context = container?.viewContext, mentions != nil {
                let request: NSFetchRequest<TwitterUser> = TwitterUser.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "handle",
            ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
            
            request.predicate = NSPredicate(format: "any tweets.text contains[c] %@ and !handle beginswith[c] %@", mentions!, "Chroniques")
                
                fetchedResultsController = NSFetchedResultsController<TwitterUser>(
                    fetchRequest: request,
                    managedObjectContext: context,
                    sectionNameKeyPath: nil,
                    cacheName: nil)
            
            try? fetchedResultsController?.performFetch()
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: variableIdentifiers.TwitterUserCell, for: indexPath)
        if let twitterUser = fetchedResultsController?.object(at: indexPath) {
            let tweetCount = tweetCountWithMentionBy(twitterUser)
            cell.textLabel?.text = twitterUser.handle
            cell.detailTextLabel?.text =
            "\(tweetCount) tweet\((tweetCount == 1) ? "" : "s"))"
        }
        
        return cell
    }
    
    private func tweetCountWithMentionBy(_ twitterUser: TwitterUser) -> Int {
        let request: NSFetchRequest<Tweet> = Tweet.fetchRequest()
        request.predicate = NSPredicate(format: "text contains[c] %@ and tweeter = %@", mentions!, twitterUser)
        return (try? twitterUser.managedObjectContext!.count(for: request)) ?? 0
    }
}
