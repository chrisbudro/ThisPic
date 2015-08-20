//
//  UserBrowseViewCell.swift
//  ParseStarterProject
//
//  Created by Chris Budro on 8/11/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class UserBrowseViewCell: UITableViewCell {

  @IBOutlet weak var userImageView: UIImageView!
  @IBOutlet weak var usernameLabel: UILabel!
  var followAction: (() -> Void)?

  @IBAction func followButtonWasPressed(sender: AnyObject) {
    followAction?()
  }
}
