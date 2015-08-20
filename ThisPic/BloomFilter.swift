//
//  BloomFilter.swift
//  ParseStarterProject
//
//  Created by Chris Budro on 8/13/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class BloomFilter: Filter {
  
  let kRadiusFactor: Float = 10
  var intensity: Float = 1.0
  var radius: Float = 10.0
  override var parameters: [NSObject: AnyObject]? {
    return [kCIInputIntensityKey: intensity, kCIInputRadiusKey: radius]
  }
  
  init() {
    super.init(filterName: "CIBloom")
  }
  
  override func hasParameters() -> Bool {
    return true
  }
  
  override func setFilterWithMultiplier(multiplier: Float) {
    intensity = multiplier
//    radius = multiplier * kRadiusFactor
  }
}
