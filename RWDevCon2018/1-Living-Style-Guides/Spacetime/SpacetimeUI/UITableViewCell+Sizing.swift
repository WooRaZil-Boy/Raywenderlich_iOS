//
//  UITableViewCell+Sizing.swift
//  SpacetimeUI
//
//  Created by Ellen Shapiro on 2/4/18.
//  Copyright © 2018 RayWenderlich.com. All rights reserved.
//

import UIKit

extension UITableViewCell {
  
  public func replaceContentViewSubviewsWith(_ view: UIView,
                                      minHeight: CGFloat = 44,
                                      margin: CGFloat = 20) {
    self.contentView.subviews.forEach { $0.removeFromSuperview() }
    
    self.contentView.addSubview(view)
    view.translatesAutoresizingMaskIntoConstraints = false
    
    
    NSLayoutConstraint.activate([
      view.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: margin),
      view.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -margin),
      view.topAnchor.constraint(equalTo: self.contentView.topAnchor),
      view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
      view.heightAnchor.constraint(greaterThanOrEqualToConstant: minHeight),
    ])

  }
  
}
