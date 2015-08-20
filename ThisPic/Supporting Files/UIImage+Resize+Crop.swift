//
//  ImageResizer.swift
//  TwitterClone
//
//  Created by Chris Budro on 8/6/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

import UIKit

extension UIImage {
  
//  func thumbnailFromSize(size: CGSize) -> UIImage? {
//    let croppedImage = self.crop()
//    
//    UIGraphicsBeginImageContextWithOptions(CGSize(width: size.width, height: size.height), false, 0.0)
//    
//    let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
//    
//    let bezierPath = UIBezierPath(roundedRect: rect, cornerRadius: size.width / 8)
//    bezierPath.addClip()
//    
//    self.drawInRect(rect)
//    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
//    UIGraphicsEndImageContext()
//    
//    return resizedImage
//  }
  
  
  func resize(size: CGSize) -> UIImage? {
    let oldWidth = self.size.width
    let newWidth = size.width
    
    let scale = newWidth / oldWidth
    let newHeight = self.size.height * scale
    
    UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth, height: newHeight), false, 0.0)

    let rect = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
    
    self.drawInRect(rect)
    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return resizedImage
  }

  func resizeWithWidth(newWidth: CGFloat) -> UIImage? {
    let oldWidth = self.size.width
    
    let scale = newWidth / oldWidth
    let newHeight = self.size.height * scale
    
    UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth, height: newHeight), false, 0.0)
    
    let rect = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
    
    self.drawInRect(rect)
    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return resizedImage
  }
  
  func crop() -> UIImage? {
    if size.width != size.height {
      var rect = CGRect()
      let sideLength = min(size.width, size.height)
      if sideLength == size.height {
        rect = CGRect(x: size.width / 4, y: 0, width: sideLength, height: sideLength)
      } else if sideLength == size.width {
        rect = CGRect(x: 0, y: size.height / 4, width: sideLength, height: sideLength)
      }
      let imageRef = CGImageCreateWithImageInRect(self.CGImage, rect)
      let resizedImage = UIImage(CGImage: imageRef)
      
      return resizedImage
    }
    return self
  }
}