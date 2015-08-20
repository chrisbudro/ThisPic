//
//  FilterThumbImageView.swift
//  ParseStarterProject
//
//  Created by Chris Budro on 8/15/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class FilterThumbImageView: UIImageView {

    // Help from a stack overflow post - attempting a more efficient way to round corners
    override func drawRect(rect: CGRect) {
      let bounds = self.bounds
      let bezierPath = UIBezierPath(roundedRect: rect, cornerRadius: rect.size.width / 8)
      bezierPath.addClip()
      
      self.image?.drawInRect(bounds)
    }
}
