//
//  CGSize+Scale.swift
//  ParseStarterProject
//
//  Created by Chris Budro on 8/14/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

extension CGSize {
  func withDeviceScale() -> CGSize {
    let width = self.width * UIScreen.mainScreen().scale
    let height = self.height * UIScreen.mainScreen().scale
    return CGSize(width: width, height: height)
  }
}

