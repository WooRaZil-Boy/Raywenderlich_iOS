//
//  UILabel+Success.swift
//  Spacetime
//
//  Created by Ellen Shapiro on 10/25/17.
//  Copyright © 2017 RayWenderlich.com. All rights reserved.
//

import UIKit

extension UILabel {
  
  func spc_configureForSuccess(_ success: Bool) {
    if success {
      self.textColor = UIColor.spc_from(r: 3, g: 91, b: 18)
    } else {
      self.textColor = UIColor.spc_from(r: 135, g: 20, b: 12)
    }
  }
}
