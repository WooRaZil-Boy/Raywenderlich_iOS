//
//  RoverCell.swift
//  Spacetime
//
//  Created by Ellen Shapiro on 10/22/17.
//  Copyright © 2017 RayWenderlich.com. All rights reserved.
//

import UIKit

class RoverCell: UITableViewCell {
  
  static let identifier = "RoverCell"
  
  @IBOutlet private var nameLabel: UILabel!
  @IBOutlet private var launchDateLabel: UILabel!
  @IBOutlet private var lastPhotoDateLabel: UILabel!
  @IBOutlet private var statusLabel: UILabel!

  func configure(for rover: NASAMarsRover) {
    self.nameLabel.text = rover.name
    self.launchDateLabel.text = UserVisibleString.launchDateString(for: rover.launchDate)
    self.lastPhotoDateLabel.text = UserVisibleString.lastPhotoDateString(for: rover.mostRecentEarthDateForPhotos)
    self.statusLabel.text = rover.status.rawValue.capitalized
    
    switch rover.status {
    case .active:
      self.statusLabel.spc_configureForSuccess(true)
    case .complete:
      self.statusLabel.spc_configureForSuccess(false)
    }    
  }
}
