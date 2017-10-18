//
//  RecentTableViewController.swift
//  Smashtag
//
//  Created by User on 16.10.2017.
//  Copyright © 2017 ZaurNNov. All rights reserved.
//

import UIKit

class RecentTableViewController: UITableViewController {

    var recentSearches: [String] {
        return RecentSearches.searches
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        tableView.reloadData()
    }
    
    private struct Storyboard {
        
        
    }
    private struct variableIdentifiers {
        //for cell
        static let RecentCell = "RecentCell"
        
        //for segue
        static let TweetsSegue = "ShowFromRecent"
        static let SearchTerm = "SearchTerm"
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentSearches.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: variableIdentifiers.RecentCell, for: indexPath) as UITableViewCell
        
        cell.textLabel?.text = recentSearches[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            RecentSearches.removeAtIndex(indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let identifier = segue.identifier , identifier == variableIdentifiers.TweetsSegue,
            let cell = sender as? UITableViewCell,
            let ttvc = segue.destination as? TweetTableViewController {
            
            ttvc.searchText = cell.textLabel?.text
            
        }  else if let identifier = segue.identifier , identifier == variableIdentifiers.SearchTerm,
            let cell = sender as? UITableViewCell,
            let pvc = segue.destination as? SmashTweetersTableViewController
        {
            pvc.mentions = cell.textLabel?.text
            pvc.container = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
            pvc.title = "Popularity for " + (cell.textLabel?.text ?? "")
        }
        
    }

}
