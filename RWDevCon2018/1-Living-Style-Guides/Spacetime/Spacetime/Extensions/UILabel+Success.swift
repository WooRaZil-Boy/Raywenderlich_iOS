//
//  UILabel+Success.swift
//  Spacetime
//
//  Created by Ellen Shapiro on 10/25/17.
//  Copyright © 2017 RayWenderlich.com. All rights reserved.
//

import SpacetimeUI
import UIKit

extension UILabel {
  
  func spc_configureForSuccess(_ success: Bool) {
    if success {
      self.textColor = SpacetimeColor.success.color
    } else {
      self.textColor = SpacetimeColor.failure.color
    }
  }
}
