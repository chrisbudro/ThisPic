//
//  GalleryViewController.swift
//  ParseStarterProject
//
//  Created by Chris Budro on 8/10/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Photos

protocol GalleryViewControllerDelegate : class {
  func galleryDidSelectImage(image: UIImage)
}

class GalleryViewController: UIViewController {
  
  //MARK: Constants
  let kMinimumCellScale: CGFloat = 0.49 // min scale to have exactly 8 columns of cells
  let kMaximumCellScale: CGFloat = 4 // max scale to have exactly one column of cells
  
  let kOptimizedImageSize = CGSize(width: 600, height: 600)

  //MARK: Outlets
  @IBOutlet weak var collectionView: UICollectionView!
  
  //MARK: Properties
  var fetchResult: PHFetchResult!
  let imageManager = PHCachingImageManager.defaultManager()
  weak var delegate: GalleryViewControllerDelegate?
  var fullImageSize: CGSize?
  var pinchScale: CGFloat = 1
  var initialScale: CGFloat = 1
  var cellSize: CGSize!
  var initialCellWidth: CGFloat {
    let initialNumberOfDividers: CGFloat = 3
    let initialNumberOfColumns: CGFloat = 4
    return (UIScreen.mainScreen().bounds.width - initialNumberOfDividers) / initialNumberOfColumns
  }
  let imagePicker = UIImagePickerController()
  var photoAssetCollection: PHAssetCollection?
  
  //MARK: Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setCellSize()
    
    imagePicker.delegate = self
    
    if UIImagePickerController.isSourceTypeAvailable(.Camera) {
      let cameraButton = UIBarButtonItem(title: "Use Camera", style: .Plain, target: self, action: "presentCamera")
      navigationItem.rightBarButtonItem = cameraButton
    }

    // Grab Photo Library
    let fetchOptions = PHFetchOptions()
    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    if let photoAssetCollection = photoAssetCollection {
      fetchResult = PHAsset.fetchAssetsInAssetCollection(photoAssetCollection, options: fetchOptions)
    }
    
    collectionView.delegate = self
    collectionView.dataSource = self
    
    let pinchGesture = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
    collectionView.addGestureRecognizer(pinchGesture)
  }
  
  //MARK: Helper Methods
  
  func presentCamera() {
    imagePicker.sourceType = .Camera
    presentViewController(self.imagePicker, animated: true, completion: nil)
  }
  
  func setPincherScale(scale: CGFloat) {
    if scale < kMinimumCellScale {
      pinchScale = kMinimumCellScale
    } else if scale > kMaximumCellScale {
      pinchScale = kMaximumCellScale
    } else {
      pinchScale = scale
    }
  }
  
  func setCellSize() {
    let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    let cellWidth = initialCellWidth * pinchScale
    let numberOfColumns = floor(UIScreen.mainScreen().bounds.width / cellWidth)
    let numberOfDividers = numberOfColumns - 1
    let perfectCellWidth = (UIScreen.mainScreen().bounds.width - (layout.minimumInteritemSpacing * numberOfDividers)) / numberOfColumns
    let perfectItemSize = CGSize(width: perfectCellWidth, height: perfectCellWidth)
    layout.itemSize = perfectItemSize
    layout.invalidateLayout()
    cellSize = perfectItemSize
    
  }

  func handlePinch(pinch: UIPinchGestureRecognizer) {
    let pinchLayout = collectionView.collectionViewLayout
    
    if pinch.state == .Began {
      initialScale = pinchScale
    }
    
    if pinch.state == .Changed {
      setPincherScale(initialScale * pinch.scale)
      let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
      let cellWidth = initialCellWidth * pinchScale
      layout.itemSize = CGSize(width: cellWidth, height: cellWidth)
      layout.invalidateLayout()
    }
    
    if pinch.state == .Ended {
      setPincherScale(initialScale * pinch.scale)
      collectionView.performBatchUpdates({ () -> Void in
        self.setCellSize()
      }, completion: nil)
    }
  }
}

//MARK: - Collection View Data Source
extension GalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return fetchResult.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! GalleryViewCell

    if let asset = fetchResult[indexPath.row] as? PHAsset {
      imageManager.requestImageForAsset(asset, targetSize: cellSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (image, info) -> Void in
        cell.imageView.image = image
      }
    }
    return cell
  }
  
  //MARK: Collection View Delegate
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if let asset = fetchResult[indexPath.row] as? PHAsset {
      let options = PHImageRequestOptions()
//      options.deliveryMode = .HighQualityFormat
      options.networkAccessAllowed = true
      let targetSize = CGSize(width: 1544, height: 1544) // assuming a framework bug. 1544 is the minimum size that will download from the cloud
      imageManager.requestImageForAsset(asset, targetSize: targetSize , contentMode: PHImageContentMode.AspectFill, options: options) { (image, info) -> Void in
        println("handler called")
        if let image = image where info[PHImageResultIsDegradedKey] as! Bool != true {
          self.delegate?.galleryDidSelectImage(image)
          self.collectionView.deselectItemAtIndexPath(indexPath, animated: true)
          self.navigationController?.popToRootViewControllerAnimated(true)
        }
      }
    }
  }
}

//MARK: - Image Picker Delegate
extension GalleryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
      self.delegate?.galleryDidSelectImage(image)
      self.navigationController?.popViewControllerAnimated(true)
    }
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
}