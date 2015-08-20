//
//  sepiaFilter.swift
//  ParseStarterProject
//
//  Created by Chris Budro on 8/13/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class SepiaFilter: Filter {
  var intensity: Float = 1.0
  override var parameters: [NSObject: AnyObject] {
    return [kCIInputIntensityKey: intensity]
  }
  
  init() {
    super.init(filterName: "CISepiaTone")
  }
  
  override func hasParameters() -> Bool {
    return true
  }
  
  override func setFilterWithMultiplier(multiplier: Float) {
    self.intensity = multiplier
  }
}