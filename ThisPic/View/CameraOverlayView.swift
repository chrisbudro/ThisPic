//
//  CameraOverlayView.swift
//  ParseStarterProject
//
//  Created by Chris Budro on 8/11/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class CameraOverlayView: UIView {
  
  @IBOutlet weak var libraryThumbnailButton: UIButton!
  var libraryButtonAction: (() -> Void)?

  @IBAction func libraryButtonWasPressed() {
    println("button pressed")
  }

}
