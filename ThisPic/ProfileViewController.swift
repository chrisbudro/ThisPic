//
//  ProfileViewController.swift
//  ParseStarterProject
//
//  Created by Chris Budro on 8/11/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import ParseUI
import Parse

class ProfileViewController: UIViewController {
  
  //MARK: Outlets
  @IBOutlet weak var profileImageButton: UIButton!
  @IBOutlet weak var username: UILabel!

  //MARK: Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    loadCurrentUser(PFUser.currentUser())
  }

  //MARK: Helper Methods
  func loadCurrentUser(user: PFUser?) {
    if let currentUser = user {
      self.navigationItem.title = currentUser.username
      username.text = currentUser.username
      if let profileImageFile = currentUser["profileImage"] as? PFFile {
        profileImageFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
          if let data = data {
            self.profileImageButton.setImage(UIImage(data: data), forState: .Normal)
          }
        })
      }
      let logoutButton = UIBarButtonItem(title: "Logout", style: .Done, target: self, action: "logoutWasPressed")
      navigationItem.rightBarButtonItem = logoutButton
    } else {
      showLogin()
    }
  }
  
  func showLogin() {
    let loginViewController = PFLogInViewController()
    loginViewController.delegate = self
    loginViewController.signUpController?.delegate = self
    presentViewController(loginViewController, animated: true, completion: nil)
  }
  
  //MARK: Actions
  func logoutWasPressed() {
    PFUser.logOutInBackgroundWithBlock { (error) -> Void in
      if let error = error {
        //TODO: add logout failed alert controller
      } else {
        self.profileImageButton.setImage(nil, forState: .Normal)
        self.username.text = nil
        self.navigationItem.title = nil
        self.showLogin()
      }
    }
  }

  @IBAction func profileImageWasPressed() {
    
  }
}


extension ProfileViewController: PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
  
  //MARK: Parse LoginViewController Delegate
  func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
    println(user)
    dismissViewControllerAnimated(true, completion: { () -> Void in
      self.loadCurrentUser(user)
    })
  }
  
  func logInViewControllerDidCancelLogIn(logInController: PFLogInViewController) {
    println("canceled")
    let loginButton = UIBarButtonItem(title: "Login", style: .Done, target: self, action: "showLogin")
    self.navigationItem.rightBarButtonItem = loginButton
  }
  
  //MARK: Parse SignUpViewController Delegate
  func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
    dismissViewControllerAnimated(true, completion: nil)
  }
}
