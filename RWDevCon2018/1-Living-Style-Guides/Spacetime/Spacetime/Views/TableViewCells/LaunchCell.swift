//
//  LaunchCell.swift
//  Spacetime
//
//  Created by Ellen Shapiro on 10/22/17.
//  Copyright © 2017 RayWenderlich.com. All rights reserved.
//

import UIKit

class LaunchCell: UITableViewCell {
  
  static let identifier = "LaunchCell"

  @IBOutlet private var launchPatchImageView: UIImageView!
  @IBOutlet private var launchNumberRocketNameLabel: UILabel!
  @IBOutlet private var imageLoadingView: UIActivityIndicatorView!
  @IBOutlet private var launchStatusLabel: UILabel!
  @IBOutlet private var landingStatusLabel: UILabel!
  @IBOutlet private var launchLocationDateLabel: UILabel!
  @IBOutlet private var recycledBoosterLabel: UILabel!
  @IBOutlet private var landingLocationLabel: UILabel!
  
  // SingleImageLoading conformance
  var imageLoadTask: URLSessionTask?
  
  override func prepareForReuse() {
    super.prepareForReuse()
    self.imageLoadTask?.cancel()
    self.launchPatchImageView.image = nil
  }
  
  func configureForLaunch(_ launch: SpaceXLaunch) {
    self.launchNumberRocketNameLabel.text = UserVisibleString.launchTitleString(for: launch.flightNumber, and: launch.rocket.name)
    self.launchLocationDateLabel.text = UserVisibleString.launchString(for: launch.launchDate, and: launch.launchSite.site.shortName)
    
    self.recycledBoosterLabel.text = UserVisibleString.boosterRecycledString(for: launch.reusedLaunchVehicle)
    
    self.launchStatusLabel.text = UserVisibleString.launchStatusString(for: launch.launchSucceeded)
    self.launchStatusLabel.spc_configureForSuccess(launch.launchSucceeded)
    
    self.landingStatusLabel.text = UserVisibleString.landingStatusString(for: launch.landingSucceeded)
    self.landingStatusLabel.spc_configureForSuccess(launch.landingSucceeded)
    
    self.landingLocationLabel.text = launch.landingType?.descriptionEmoji
    self.recycledBoosterLabel.text = UserVisibleString.boosterRecycledEmoji(for: launch.reusedLaunchVehicle)
    
    self.loadImage(for: launch.links.missionPatchImage)
  }
}

//MARK: - Single Image Loading

extension LaunchCell: SingleImageLoading {  
  
  var loadingView: UIActivityIndicatorView! {
    return self.imageLoadingView
  }
  
  var targetImageView: UIImageView! {
    return self.launchPatchImageView
  }
}
