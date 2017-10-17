//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by ZaurNNov on 15.10.2017.
//  Copyright © 2017 ZaurNNov. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
        }
    }
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        searchForTweets()
    }
    
    //in keyboard activate "search" buttun
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTextField {
            searchText = searchTextField.text
        }
        return true
    }
    
    private var tweets = [Array<Twitter.Tweet>]() {
        didSet {
            //print(tweets)
        }
    }
    
    var newTweets = Array<Twitter.Tweet> () {
        didSet {
            tweets.insert(newTweets, at:0)
            tableView.insertSections([0], with: .fade)
        }
    }
    
    var searchText: String? {
        didSet {
            searchTextField?.text = searchText
            searchTextField?.resignFirstResponder()
            lastTwitterRequest = nil
            
            tweets.removeAll()
            tableView.reloadData()
            searchForTweets()
            title = searchText
            
            //save recent search in array
            if let term = searchText {
                RecentSearches.addRecents(term)
            }
        }
    }
    
    func insertTweets(_ newTweets: [Twitter.Tweet]) {
        self.tweets.insert(newTweets, at: 0)
        self.tableView.insertSections([0], with: .fade)
    }
    
    private func twitterRequest() -> Twitter.Request? {
        if let query = searchText, !query.isEmpty {
            return Twitter.Request(search: "\(query) -filter:safe -filter:retweets", count: 100)
        }
        return nil
    }
    
    private var lastTwitterRequest: Twitter.Request?
    
    private func searchForTweets() {
        if let request = lastTwitterRequest?.newer ?? twitterRequest() {
            lastTwitterRequest = request
            //of the main queue
            request.fetchTweets { [weak self] newTweets in
                //off the main queue
                DispatchQueue.main.async {
                    //back to main queue
                    if request == self?.lastTwitterRequest {
                        self?.insertTweets(newTweets)
                        
                    }
                    //refreshing
                    self?.refreshControl?.endRefreshing()
                }
            }
        } else {
            self.refreshControl?.endRefreshing() // REFRESHING
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        //searchText = variableIdentifiers.searchHashtagText
        if tweets.count == 0 {
            if searchText == nil, let searchLast = RecentSearches.searches.first {
                searchText = searchLast
            } else {
                searchTextField?.text = searchText
                searchTextField?.resignFirstResponder()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - UITableViewDataSourse
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tweets.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: variableIdentifiers.TweetCell, for: indexPath)
        
        let tweet: Twitter.Tweet = tweets[indexPath.section][indexPath.row]

        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(tweets.count-section)"
    }
    
    private struct variableIdentifiers {
        //for cell
        static let TweetCell = "Tweet"
        //for segue
        static let ShowMentions = "ShowMentions"
        static let ShowImages = "ShowImages"
        //other
        static let searchHashtagText = "#iOS"
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
