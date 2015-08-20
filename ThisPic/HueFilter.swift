//
//  HueFilter.swift
//  ParseStarterProject
//
//  Created by Chris Budro on 8/13/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class HueFilter: Filter {
  var angle: Float = 0.5
  override var parameters: [NSObject: AnyObject]? {
    return [kCIInputAngleKey: angle]
  }
  
  init() {
    super.init(filterName: "CIHueAdjust")
  }
  
  override func hasParameters() -> Bool {
    return true
  }
  
  override func setFilterWithMultiplier(multiplier: Float) {
    angle = multiplier
  }
}