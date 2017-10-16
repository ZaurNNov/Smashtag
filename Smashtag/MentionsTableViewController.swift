//
//  MentionsTableViewController.swift
//  Smashtag
//
//  Created by ZaurNNov on 16.10.2017.
//  Copyright © 2017 ZaurNNov. All rights reserved.
//

import UIKit
import Twitter

class MentionsTableViewController: UITableViewController {
    
    // Twiiter
    var tweet: Twitter.Tweet? {
        didSet {
            guard let tweet = tweet else {return}
            title = tweet.user.screenName
            mentionsSections = initMentionSections(from: tweet)
            tableView.reloadData()
        }
    }
    
    // Mentions
    private var mentionsSections: [MentionSection] = [] //mentions array
    private struct MentionSection {
        var type: String
        var mentions: [MentionItem]
    }
    
    //for mentions:
    private enum MentionItem {
        case keyword(String) // hashtag, urls, users
        case image(URL, Double) // url - url image, double - aspect ratio)
    }
    
    private func initMentionSections(from tweet: Twitter.Tweet) -> [MentionSection]
    {
        var funcMentionsSections = [MentionSection]()
        
        if tweet.media.count > 0 {
            funcMentionsSections.append(MentionSection(
                type: "Images",
                mentions: tweet.media.map{ MentionItem.image($0.url, $0.aspectRatio)}))
        }
        if tweet.urls.count > 0 {
            funcMentionsSections.append(MentionSection(type: "URLs", mentions: tweet.urls.map{ MentionItem.keyword($0.keyword)}))
        }
        if tweet.hashtags.count > 0 {
            funcMentionsSections.append(MentionSection(type: "Hashtags", mentions: tweet.hashtags.map{ MentionItem.keyword($0.keyword)}))
        }
        if tweet.userMentions.count > 0 {
            funcMentionsSections.append(MentionSection(type: "Users", mentions: tweet.userMentions.map{ MentionItem.keyword($0.keyword)}))
        }
        
        return funcMentionsSections
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return mentionsSections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mentionsSections[section].mentions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let mention = mentionsSections[indexPath.section].mentions[indexPath.row]
        switch mention {
        case .keyword(let keyword):
            let cell = tableView.dequeueReusableCell(withIdentifier: variableIdentifiers.KeyCell, for: indexPath)
            cell.textLabel?.text = keyword
            return cell
        
        case .image(let url, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: variableIdentifiers.ImageCell, for: indexPath)
            if let imageCell = cell as? ImageTableViewCell {
                imageCell.imageUrl = url
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let mention = mentionsSections[indexPath.section].mentions[indexPath.row]
        switch mention {
        case .image(_, let ratio):
            return tableView.bounds.size.width / CGFloat(ratio)
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return mentionsSections[section].type
    }
    
    private struct variableIdentifiers {
        //for cell
        static let KeyCell = "KeyCell"
        static let ImageCell = "ImageCell"
        
        //for segue
        static let ShowMentions = "ShowMentions"
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
