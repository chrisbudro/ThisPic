//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse
import QuartzCore
import Photos

class ImageViewController: UIViewController {
  
  //MARK: Constants
  let kThumbnailCellSize = CGSize(width: 70, height: 70)
//  let kOptimizedImageSize = CGSize(width: 600, height: 600)
  let kCollectionViewAnimationOffscreenConstraint: CGFloat = -80
  let kCollectionViewOriginalHeight: CGFloat = 80
  let kCollectionViewOnScreenConstraint: CGFloat = 0
  let kImageWidthForPostUpload: CGFloat = 1200
  
  //MARK: Outlets
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet private weak var mainImageView: UIImageView!
  @IBOutlet weak var intensitySlider: UISlider!
  @IBOutlet weak var closeFilterModeButton: UIButton!
  @IBOutlet weak var applyFilterButton: UIButton!
  
  
  //MARK: Constraints
  @IBOutlet weak var imageViewBottomToFilterThumbnailConstraint: NSLayoutConstraint!
  @IBOutlet weak var imageViewToBottomGuideConstraint: NSLayoutConstraint!
  @IBOutlet weak var collectionConstraint: NSLayoutConstraint!
 
  
  //MARK: Properties
  var currentImage: UIImage? {
    willSet {
      if newValue != nil {
        let postButton = UIBarButtonItem(title: "Post", style: .Done, target: self, action: "postWasPressed")
        navigationItem.rightBarButtonItem = postButton
      } else {
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil
      }
    }
    didSet {
//      assignDisplayImage(mainImageView.bounds.size)
      assignDisplayImage(CGSize(width: 160, height: 160))
      thumbnail = currentImage?.resizeWithWidth(kThumbnailCellSize.width)
      if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
        openFilterMode()
      } else if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
        let clearButton = UIBarButtonItem(title: "Clear Filter", style: .Plain, target: self, action: "clearFilter")
        navigationItem.leftBarButtonItem = clearButton
      }
      self.collectionView.reloadData()
    }
  }
  var displayImage: UIImage?
  var currentFilter: Filter?
  var thumbnail: UIImage?
  var filters: [Filter] {
    return FilterService.shared.filters
  }
  var inFilterMode: Bool = false
  var galleryTapGesture = UITapGestureRecognizer()

  //MARK: Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    galleryTapGesture = UITapGestureRecognizer(target: self, action: "segueToGallery")
    mainImageView.addGestureRecognizer(galleryTapGesture)
    
    intensitySlider.alpha = 0
    intensitySlider.addTarget(self, action: "filterSliderChanged:", forControlEvents: .ValueChanged)
    
    collectionView.delegate = self
    collectionView.dataSource = self
  }
  
  override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    if let window = view.window {
      assignDisplayImage(size)
      if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
        coordinator.animateAlongsideTransition ({ (context) -> Void in
          
          if self.inFilterMode {
            self.collectionConstraint.constant = self.kCollectionViewOnScreenConstraint
          } else {
            self.collectionConstraint.constant = self.kCollectionViewAnimationOffscreenConstraint
          }
          self.view.layoutIfNeeded()
          }, completion: nil)
      }
    }
  }

  //MARK: Button Actions

  @IBAction func closeFilterModeWasPressed() {
    closeFilterMode()
    clearFilter()
  }
  
  @IBAction func applyFilterWasPressed() {
    closeFilterMode()
  }

  func postWasPressed() {
    let resizedImage = currentImage?.resizeWithWidth(kImageWidthForPostUpload)
    
    FilterService.shared.filteredImageFromImage(resizedImage, withFilter: currentFilter, completion: { (image) -> Void in
      if let image = image {
        self.prepareCaptionForPost({ (caption) -> Void in
          ParseService.uploadPost(image, caption: caption) { (success, error) in
            if let error = error {
              //TODO: Setup Error Alert Controller "Post did not upload: error description"
            } else if success {
              self.dismissViewControllerAnimated(true, completion: nil)
              self.closeFilterMode()
            }
          }
        })
      }
    })
  }

  func filterSliderChanged(slider: UIControl) {
    if let currentFilter = currentFilter where currentFilter.hasParameters() {
      currentFilter.setFilterWithMultiplier(self.intensitySlider.value)
      FilterService.shared.filteredImageFromContinuousImage(displayImage, withFilter: currentFilter) { (filteredImage) -> Void in
        self.mainImageView.image = filteredImage
      } 
    }
  }
  
  //MARK: Helper Methods
  
  func assignDisplayImage(size: CGSize) {
    displayImage = currentImage?.resizeWithWidth(size.width)
    mainImageView.image = displayImage
  }
  
  func openFilterMode() {
    mainImageView.removeGestureRecognizer(galleryTapGesture)
    closeFilterModeButton.enabled = true
    applyFilterButton.enabled = true
    self.navigationController?.setNavigationBarHidden(true, animated: true)
    UIView.animateWithDuration(0.1, animations: { () -> Void in
      self.closeFilterModeButton.alpha = 1.0
      self.applyFilterButton.alpha = 1.0
      self.collectionConstraint.constant = self.kCollectionViewOnScreenConstraint
      self.imageViewToBottomGuideConstraint.active = false
      self.imageViewBottomToFilterThumbnailConstraint.active = true
      self.view.layoutIfNeeded()
      }) { (succeeded) -> Void in
        self.inFilterMode = true
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "filterDoneWasPressed")
        self.navigationItem.leftBarButtonItem = cancelButton
    }
  }
  
  func closeFilterMode() {
    mainImageView.addGestureRecognizer(galleryTapGesture)
    closeFilterModeButton.enabled = false
    applyFilterButton.enabled = false
    navigationController?.setNavigationBarHidden(false, animated: true)
    UIView.animateWithDuration(0.1, animations: { () -> Void in
      self.closeFilterModeButton.alpha = 0
      self.applyFilterButton.alpha = 0
      self.collectionConstraint.constant = self.kCollectionViewAnimationOffscreenConstraint
      self.imageViewBottomToFilterThumbnailConstraint.active = false
      self.imageViewToBottomGuideConstraint.active = true
      self.view.layoutIfNeeded()
      self.hideSlider()
      }) { (succeeded) -> Void in
        self.inFilterMode = false
        let filterBarButton = UIBarButtonItem(title: "Filter", style: .Plain, target: self, action: "openFilterMode")
        self.navigationItem.leftBarButtonItem = filterBarButton
    }
  }
  
  func clearFilter() {
    mainImageView.image = displayImage
  }
  
  func showSlider() {
    UIView.animateWithDuration(0.5) { () -> Void in
      self.intensitySlider.alpha = 1.0
      self.intensitySlider.enabled = true
    }
  }
  
  func hideSlider() {
    UIView.animateWithDuration(0.5) { () -> Void in
      self.intensitySlider.alpha = 0.0
      self.intensitySlider.enabled = false
    }
  }
  
  func segueToGallery() {
    performSegueWithIdentifier("ShowAlbumList", sender: self)
  }

  func prepareCaptionForPost(handler: (caption: String?) -> Void) {
    let captionsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("captionsViewController") as! CaptionsViewController
    captionsViewController.shareAction = { (caption) in
      captionsViewController.shareButton.enabled = true
      handler(caption: caption)
    }
    self.presentViewController(captionsViewController, animated: true, completion: nil)
  }
  
  //MARK: Segue
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowAlbumList" {
      let vc = segue.destinationViewController as! PhotoAlbumViewController
      vc.delegate = self
      vc.fullImageSize = self.mainImageView.frame.size.withDeviceScale()
    }
  }
}

//MARK: - Collection View Data Source
extension ImageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return filters.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! FilterThumbnailCell
    cell.imageView.image = nil
    let filter = filters[indexPath.row]
    if let thumbnail = thumbnail {
      FilterService.shared.filteredImageFromImage(thumbnail, withFilter: filter) { (filteredThumbnail) -> Void in
        cell.imageView.image = filteredThumbnail
      }
    }
    return cell
  }
  
  //MARK: Collection View Delegate
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let filter = filters[indexPath.row]
    if let currentImage = currentImage {
      if filter.hasParameters() {
        intensitySlider.setValue(0.5, animated: true)
        filter.setFilterWithMultiplier(self.intensitySlider.value)
        showSlider()
      } else {
        if self.intensitySlider.alpha != 0 || self.intensitySlider.enabled == true {
          hideSlider()
        }
      }
      FilterService.shared.filteredImageFromImage(displayImage, withFilter: filter, completion: { (filteredImage) -> Void in
        self.mainImageView.image = filteredImage
        self.currentFilter = filter
      })
    }
  }
}

//MARK: - Gallery View Controller Delegate
extension ImageViewController: GalleryViewControllerDelegate {
  func galleryDidSelectImage(image: UIImage) {
    currentImage = image
  }
}







