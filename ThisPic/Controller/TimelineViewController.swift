//
//  TimelineViewController.swift
//  ParseStarterProject
//
//  Created by Chris Budro on 8/10/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class TimelineViewController: UITableViewController {
  
  //MARK: Constants
  let kEstimatedRowHeight: CGFloat = 400
  let kEstimatedSectionHeaderHeight: CGFloat = 60
  let kImageViewIndex = 0
  let kCommentViewIndex = 1
  
  //MARK: Properties
  var posts = [PFObject]()
  let imageProcessingQueue = NSOperationQueue()

  //MARK: Main
  override func viewDidLoad() {
    super.viewDidLoad()
    
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: "getTimeline", forControlEvents: .ValueChanged)
    
    tableView.estimatedRowHeight = kEstimatedRowHeight
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedSectionHeaderHeight = kEstimatedSectionHeaderHeight
    tableView.sectionHeaderHeight = UITableViewAutomaticDimension
    
    title = "Timeline"

    getTimeline()

  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if PFUser.currentUser() == nil {
      if !posts.isEmpty {
        posts = []
        tableView.reloadData()
      }
      tabBarController?.selectedIndex = TabBarTabs.Profile.rawValue
    } else if posts.isEmpty {
      getTimeline()
    }
  }
  
  func getTimeline() {
    ParseService.getTimeline { (posts, error) -> Void in
      NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
        if let posts = posts {
          self.posts = posts
          self.tableView.reloadData()
        }
        self.refreshControl?.endRefreshing()
      }
    }
  }
  
  // MARK: - Table view data source
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return posts.count
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }
  
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let viewArray = NSBundle.mainBundle().loadNibNamed("TimelineSectionHeaderView", owner: self, options: nil)
    if let headerView = viewArray.first as? TimelineSectionHeaderView {
      headerView.profileImageView.alpha = 0
      let post = posts[section]
      if let user = post["user"] as? PFObject {
        user.fetchIfNeededInBackgroundWithBlock { (userObject, error) -> Void in
          if let userObject = userObject {
            if let username = userObject["username"] as? String {
              headerView.usernameTextLabel.text = username
            }
            if let profileImageFile = userObject["profileImage"] as? PFFile {
              profileImageFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if let data = data {
                  headerView.profileImageView.image = UIImage(data: data)
                  UIView.animateWithDuration(0.3) {
                    headerView.profileImageView.alpha = 1.0
                  }
                }
              })
            }
          }
        }
      }
      return headerView
    }
    return nil
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if indexPath.row == kImageViewIndex {
      let post = posts[indexPath.section]
      if let aspectRatio = post["imageAspectRatio"] as? CGFloat {
        return tableView.bounds.width * aspectRatio
      }
    }
    return UITableViewAutomaticDimension
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let post = posts[indexPath.section]
    var cell = TimelinePostCell()
    if indexPath.row == kImageViewIndex {
      cell = tableView.dequeueReusableCellWithIdentifier("ImageCell", forIndexPath: indexPath) as! TimelinePostCell
      cell.postImageView.image = nil
      cell.postImageView.alpha = 0
      let tag = cell.tag
      
      if let imageFile = post["image"] as? PFFile {
        imageFile.getDataInBackgroundWithBlock { (data, error) -> Void in
          self.imageProcessingQueue.addOperationWithBlock {
            
            if let error = error {
              //TODO: add alert for error
            } else if let
              data = data,
              image = UIImage(data: data),
              resizedImage = image.resizeWithWidth(UIScreen.mainScreen().bounds.width)
            {
              NSOperationQueue.mainQueue().addOperationWithBlock {
                if tag == cell.tag {
                  cell.postImageView.image = resizedImage
                  cell.postImageView.sizeToFit()
                  UIView.animateWithDuration(0.1) {
                    cell.postImageView.alpha = 1.0
                  }
                }
              }
            }
          }
        }
      }
    }
    if indexPath.row == kCommentViewIndex {
      cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! TimelinePostCell
      cell.commentsTextLabel.text = nil
      if let caption = post["caption"] as? String {
        cell.commentsTextLabel.text = caption
      }
    }
    return cell
  }
  
  //MARK: Table View Delegate
  override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
  }
}
