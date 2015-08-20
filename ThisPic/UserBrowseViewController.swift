//
//  UserBrowseViewController.swift
//  ParseStarterProject
//
//  Created by Chris Budro on 8/11/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class UserBrowseViewController: UITableViewController {
  
  //MARK: Properties
  var users = [PFObject]()
  
  //MARK: Main
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Users"
    
    ParseService.getUserList { (users, error) -> Void in
      NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
        if let error = error {
          //TODO: Add error alert controller
        } else if let users = users {
          self.users = users
          self.tableView.reloadData()
        }
      }
    }
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return users.count
  }
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UserBrowseViewCell
    
    let user = users[indexPath.row]
    user.fetchIfNeededInBackgroundWithBlock { (userObject, error) -> Void in
      if let
        userObject = userObject {
          if let username = userObject["username"] as? String {
            cell.usernameLabel.text = username
          }
          if let profileImageFile = userObject["profileImage"] as? PFFile {
            profileImageFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
              if let data = data {
                cell.userImageView.image = UIImage(data: data)
              }
            })
          }
      }
    }
    cell.followAction = {
      ParseService.followUser(user) { (succeeded, error) in
        
      }
    }
    return cell
  }
}
