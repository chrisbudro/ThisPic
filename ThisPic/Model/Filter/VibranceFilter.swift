//
//  VibranceFilter.swift
//  ParseStarterProject
//
//  Created by Chris Budro on 8/13/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class VibranceFilter: Filter {
  var amount: Float = 0.5
  override var parameters: [NSObject: AnyObject]? {
    return ["inputAmount": amount]
  }
  
  init() {
    super.init(filterName: "CIVibrance")
  }
  
  override func hasParameters() -> Bool {
    return true
  }
  
  override func setFilterWithMultiplier(multiplier: Float) {
    amount = multiplier
  }
}
