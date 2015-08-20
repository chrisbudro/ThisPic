//
//  PhotoAlbumViewController.swift
//  ParseStarterProject
//
//  Created by Chris Budro on 8/16/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Photos

class PhotoAlbumViewController: UITableViewController {
  
  //MARK Properties
  var albumFetchResult: PHFetchResult!
  let imageManager = PHImageManager.defaultManager()
  let imagePicker = UIImagePickerController()
  var delegate: GalleryViewControllerDelegate?
  var fullImageSize: CGSize?
  
  //MARK: Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    albumFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: nil)
    
    imagePicker.delegate = self
    
    if UIImagePickerController.isSourceTypeAvailable(.Camera) {
      let cameraButton = UIBarButtonItem(title: "Use Camera", style: .Plain, target: self, action: "presentCamera")
      navigationItem.rightBarButtonItem = cameraButton
    }
  }
  
  //MARK: Helper Methods
  
  func presentCamera() {
    self.imagePicker.sourceType = .Camera
    self.presentViewController(self.imagePicker, animated: true, completion: nil)
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return albumFetchResult.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("AlbumViewCell", forIndexPath: indexPath) as! PhotoAlbumViewCell
    cell.albumImageView.image = nil
    cell.albumNameLabel.text = nil
    
    if let album =  albumFetchResult[indexPath.row] as? PHAssetCollection {
      cell.albumNameLabel.text = "\(album.localizedTitle)"
      let albumAssets = PHAsset.fetchAssetsInAssetCollection(album, options: nil)
      if let asset = albumAssets[0] as? PHAsset {
        imageManager.requestImageForAsset(asset, targetSize: cell.albumImageView.bounds.size, contentMode: .AspectFill, options: nil, resultHandler: { (image, info) -> Void in
          cell.albumImageView.image = image
        })
      }
    }
    return cell
  }
  //MARK: - Table View Delegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if let album = albumFetchResult[indexPath.row] as? PHAssetCollection {
      performSegueWithIdentifier("ShowGallery", sender: album)
    }
  }
  
  //MARK: Navigation
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let photoAssetCollection = sender as? PHAssetCollection where segue.identifier == "ShowGallery" {
      let vc = segue.destinationViewController as! GalleryViewController
      vc.delegate = self.delegate
      vc.photoAssetCollection = photoAssetCollection
      vc.fullImageSize = fullImageSize
    }
  }
}

//MARK: - Image Picker Delegate
extension PhotoAlbumViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
