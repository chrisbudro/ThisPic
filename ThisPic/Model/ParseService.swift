//
//  ParseService.swift
//  ParseStarterProject
//
//  Created by Chris Budro on 8/10/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class ParseService {
  class func getTimeline(completion: (posts: [PFObject]?, error: String?) -> Void) {
    if let
      user = PFUser.currentUser(),
      following =  user["following"] as? [PFObject]
    {
      let query = PFQuery(className: "Post")
      query.whereKey("user", containedIn: following)
      query.orderByDescending("createdAt")
      
      query.findObjectsInBackgroundWithBlock { (posts, error) -> Void in
        if let error = error {
          completion(posts: nil, error: error.description)
        }
        if let posts = posts as? [PFObject] {
          completion(posts: posts, error: nil)
        } else {
          completion(posts: nil, error: "an unknown error occurred")
        }
      }
    }
    completion(posts: nil, error: "User is not set")
  }
  
  class func getUserList(completion: (users: [PFObject]?, error: String?) -> Void) {
    if let query = PFUser.query() {
      query.orderByAscending("username")
      query.findObjectsInBackgroundWithBlock { (users, error) -> Void in
        if let error = error {
          completion(users: nil, error: error.localizedDescription)
        } else if let users = users as? [PFObject] {
          completion(users: users, error: nil)
        } else {
          completion(users: nil, error: "An error has occurred")
        }
      }
    }
  }

  class func followUser(user: PFObject, completion: (Bool, error: String?) -> Void) {
    if let currentUser = PFUser.currentUser() {
      currentUser.addUniqueObject(user, forKey: "following")
      currentUser.saveInBackgroundWithBlock { (succeeded, error) -> Void in
        if let error = error {
          completion(false, error: error.localizedDescription)
        } else if succeeded == true {
          completion(succeeded, error: nil)
          println("followed")
        }
      }
    }
  }
  
  class func uploadPost(image: UIImage, caption: String?, completion: (Bool, error: String?) -> Void) {
    let post = PFObject(className: "Post")
    let aspectRatio = image.size.height / image.size.width
    let jpegData = UIImageJPEGRepresentation(image, 0.7)
    let imageFile = PFFile(name: "post", data: jpegData)
    post.setObject(imageFile, forKey: "image")
    post.setObject(aspectRatio, forKey: "imageAspectRatio")
    if let currentUser = PFUser.currentUser() {
      let user = PFUser.objectWithoutDataWithObjectId(currentUser.objectId)
      post.setObject(user, forKey: "user")
    }
    if let caption = caption {
      post.setObject(caption, forKey: "caption")
    }
    post.saveInBackgroundWithBlock { (success, error) -> Void in
      if let error = error {
        completion(false, error: error.localizedDescription)
      } else if success {
        completion(true, error: nil)
      }
    }
  }
}













