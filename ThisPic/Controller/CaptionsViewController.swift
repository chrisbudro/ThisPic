//
//  CaptionsViewController.swift
//  ParseStarterProject
//
//  Created by Chris Budro on 8/10/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class CaptionsViewController: UIViewController {
  
  //MARK: Outlets
  @IBOutlet weak var shareButton: UIButton!
  @IBOutlet weak var captionTextView: UITextView!
  
  //MARK: Properties
  var shareAction: ((caption: String?) -> Void)?
  var captionText: String?
  
  //MARK: Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    captionTextView.delegate = self
    if captionText == nil {
      captionTextView.textColor = UIColor.lightGrayColor()
    }
  }
  
  //MARK: Actions
  @IBAction func shareWasPressed(sender: AnyObject) {
    shareButton.enabled = false
    shareAction?(caption: captionText)
  }
  
  @IBAction func cancelWasPressed(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }
}

//MARK: Text View Delegate
extension CaptionsViewController: UITextViewDelegate {
  func textViewDidBeginEditing(textView: UITextView) {
    textView.textColor = UIColor.blackColor()
    if captionText == nil {
      captionTextView.text = nil
    }
  }
  
  func textViewDidChange(textView: UITextView) {
    captionText = textView.text
  }

  func textViewDidEndEditing(textView: UITextView) {
    captionText = textView.text
    if textView.text == "" {
      textView.text = "Add a Caption..."
      textView.textColor = UIColor.lightGrayColor()
    }
  }
}
