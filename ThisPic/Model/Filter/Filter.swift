//
//  Filter.swift
//  ParseStarterProject
//
//  Created by Chris Budro on 8/13/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class Filter {
  let filterName: String
  var parameters: [NSObject: AnyObject]? {
    return nil
  }
  
  init(filterName: String) {
    self.filterName = filterName
  }
  
  func hasParameters() -> Bool {
    return false
  }
  
  func setFilterWithMultiplier(multiplier: Float) {
    
  }
}