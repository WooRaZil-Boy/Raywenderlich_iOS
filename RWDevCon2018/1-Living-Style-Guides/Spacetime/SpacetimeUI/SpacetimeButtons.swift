//
//  SpacetimeButtons.swift
//  SpacetimeUI
//
//  Created by Ellen Shapiro on 2/4/18.
//  Copyright © 2018 RayWenderlich.com. All rights reserved.
//

import UIKit

public enum SpacetimeButtonStyle: String {
  case
  link,
  bordered
  
  var textColor: SpacetimeColor {
    switch self {
    case .link:
      return .buttonText
    case .bordered:
      return .buttonBorder
    }
  }
  
  var titleFont: SpacetimeFont {
    switch self {
    case .link:
      return .condensedBold
    case .bordered:
      return .standard
    }
  }
  
  var titleFontSize: SpacetimeFontSize {
    switch self {
    case .link:
      return .normal
    case .bordered:
      return .medium
    }
    
  }
  
  var highlightedTextColor: SpacetimeColor {
    switch self {
    case .link:
      return .success
    case .bordered:
      return .failure
    }
  }
  
  var selectedTextColor: SpacetimeColor {
    switch self {
    case .link:
      return .failure
    case .bordered:
      return .success
    }
  }
  
  var backgroundColor: SpacetimeColor? {
    switch self {
    case .link:
      return .buttonBackground
    default:
      return nil
    }
  }
  
  var borderColor: SpacetimeColor? {
    switch self {
    case .bordered:
      return self.textColor
    default:
      return nil
    }
  }
}

extension SpacetimeButtonStyle: StyleGuideViewable {

  public var view: UIView {
    let buttonsStack = UIStackView()
    buttonsStack.axis = .vertical
    buttonsStack.distribution = .fillEqually
    buttonsStack.spacing = 4
    
    let states: [UIControlState] = [
      .normal,
      .highlighted,
      .selected,
    ]

    for state in states {
      let button = SpacetimeBaseButton()
      button.buttonStyle = self
      
      button.setTitle("Normal", for: .normal)
      button.setTitle("Highlighted", for: .highlighted)
      button.setTitle("Selected", for: .selected)

      switch state {
      case .selected:
        button.isSelected = true
      case .highlighted:
        button.isHighlighted = true
      default:
        break
      }
      buttonsStack.addArrangedSubview(button)
    }
    
    return buttonsStack
  }
}

@IBDesignable
public class SpacetimeBaseButton: UIButton {
  
  var buttonStyle: SpacetimeButtonStyle! {
    didSet {
      if let backgroundColor = self.buttonStyle.backgroundColor {
        self.backgroundColor = backgroundColor.color
      }
      
      self.setTitleColor(self.buttonStyle.textColor.color, for: .normal)
      self.setTitleColor(self.buttonStyle.highlightedTextColor.color, for: .highlighted)
      self.setTitleColor(self.buttonStyle.selectedTextColor.color, for: .selected)
      
      self.titleLabel?.font = self.buttonStyle.titleFont.of(size: self.buttonStyle.titleFontSize)
      
      if let borderColor = self.buttonStyle.borderColor {
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 4
        self.layer.borderColor = borderColor.color.cgColor
      }
    }
  }
  
  func commonInit() {
    // Code here will be executed in all setup states
  }
  
  convenience init() {
    self.init(frame: .zero)
  }
  
  override public init(frame: CGRect) {
    super.init(frame: frame)
    self.commonInit()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.commonInit()
  }
  
  override public func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    self.commonInit()
  }
}

public class LinkButton: SpacetimeBaseButton {
  
  override func commonInit() {
    self.buttonStyle = .link
  }
  
}

public class BorderedButton: SpacetimeBaseButton {
  
  override func commonInit() {
    self.buttonStyle = .bordered
  }
}
