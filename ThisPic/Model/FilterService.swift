//
//  FilterService.swift
//  ParseStarterProject
//
//  Created by Chris Budro on 8/10/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//


import UIKit
import CoreImage

typealias ImageHandler = (UIImage?) -> Void

class FilterService {
  static let shared = FilterService()
  
  //MARK: Properties
  let gpuContext: CIContext
  let filterBackgroundQueue: NSOperationQueue
  var ciFilter: CIFilter?
  
  let filters = [
    SepiaFilter(),
    Filter(filterName: "CIPhotoEffectMono"),
    Filter(filterName: "CIPhotoEffectInstant"),
    Filter(filterName: "CIPhotoEffectFade"), 
    Filter(filterName: "CIPhotoEffectChrome"),
    VignetteFilter(),
    Filter(filterName: "CIPhotoEffectNoir"),
    Filter(filterName: "CIPhotoEffectProcess"),
    HueFilter(),
    Filter(filterName: "CIPhotoEffectTonal"),
    Filter(filterName: "CIPhotoEffectTransfer"),
    BloomFilter(),
    VibranceFilter(),
  ]
  
  //MARK: Init
  init() {
    var options = [kCIContextWorkingColorSpace: NSNull()]
    let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
    self.gpuContext = CIContext(EAGLContext: eaglContext, options: options)
    self.filterBackgroundQueue = NSOperationQueue()
    filterBackgroundQueue.maxConcurrentOperationCount = 1
  }

  //MARK: Methods
  func filteredImageFromImage(image: UIImage?, withFilter filter: Filter?, completion: ImageHandler) {
    if let
        image = image,
        filter = filter {
      let orientation = image.imageOrientation
      filterBackgroundQueue.addOperationWithBlock {
        let coreImage = CIImage(image: image)
        self.ciFilter = CIFilter(name: filter.filterName, withInputParameters: filter.parameters)
        self.ciFilter!.setValue(coreImage, forKey: kCIInputImageKey)
        let outputImage = self.ciFilter!.outputImage
        let extent = coreImage.extent()
        let cgImage = self.gpuContext.createCGImage(outputImage, fromRect: extent)

        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
          let filteredImage = UIImage(CGImage: cgImage, scale: UIScreen.mainScreen().scale, orientation: orientation)
          completion(filteredImage)
        }
      }
    } else {
      completion(image)
    }
  }
  
  func filteredImageFromContinuousImage(image: UIImage?, withFilter filter: Filter, completion: ImageHandler) {
    if let
      image = image,
      ciFilter = ciFilter,
      parameters = filter.parameters
    {
      let orientation = image.imageOrientation
      let coreImage = CIImage(image: image)
      filterBackgroundQueue.addOperationWithBlock {
        self.ciFilter!.setValue(coreImage, forKey: kCIInputImageKey)
        self.ciFilter!.setValuesForKeysWithDictionary(parameters)
        let outputImage = ciFilter.outputImage
        let extent = coreImage.extent()
        let cgImage = self.gpuContext.createCGImage(outputImage, fromRect: extent)
        
        NSOperationQueue.mainQueue().addOperationWithBlock {
          let filteredImage = UIImage(CGImage: cgImage, scale: UIScreen.mainScreen().scale, orientation: orientation)
          completion(filteredImage)
        }
      }
    }
  }
}