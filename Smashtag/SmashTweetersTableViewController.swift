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
        //for segue
        static let ToMainTweetTableView = "ToMainTweetTableView"
        
    }
    
    var mentions: String? {didSet{UpdateUI()}}
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer {didSet{UpdateUI()}}
    
    var fetchedResultsController: NSFetchedResultsController<Mention>?

    private func UpdateUI() {
        if let context = container?.viewContext, mentions != nil {
            let request: NSFetchRequest<Mention> = Mention.fetchRequest()
            request.sortDescriptors =
                [NSSortDescriptor(
                    key: "type",
                    ascending: true,
                    selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))),
                 NSSortDescriptor(
                    key: "count",
                    ascending: false),
                 NSSortDescriptor(
                    key: "keyword",
                    ascending: true,
                    selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
                )]

            request.predicate = NSPredicate(format:"count > 1 AND searchTerm = %@", mentions!)
            
            fetchedResultsController = NSFetchedResultsController<Mention>(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: "type",
                cacheName: nil
            )
            
            try? fetchedResultsController?.performFetch()
            fetchedResultsController?.delegate = self
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: variableIdentifiers.TwitterUserCell, for: indexPath)
        
        if let mention = fetchedResultsController?.object(at: indexPath) {
            cell.textLabel?.text = mention.keyword
            cell.detailTextLabel?.text =
            "\(mention.count) tweet\((mention.count == 1) ? "" : "s"))"
        }
        
        return cell
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            
            if identifier == variableIdentifiers.ToMainTweetTableView {
                if let ttvc = segue.destination as? TweetTableViewController,
                    let cell = sender as? UITableViewCell,
                    var text = cell.textLabel?.text {
                    if text.hasPrefix("@") {text += " OR from:" + text}
                    ttvc.searchText = text
                }
                
            }
        }
    }

}
