//
//  StyleGuideViewable.swift
//  SpacetimeUI
//
//  Created by Ellen Shapiro on 3/25/18.
//  Copyright © 2018 RayWenderlich.com. All rights reserved.
//

import Foundation

public protocol StyleGuideViewable {
  
  static var styleName: String { get } //스타일 자체의 이름

  var itemName: String { get } //스타일의 각 항목에 대한 이름
  
  var rawValue: String { get }
    //enum이 String으로 선언된 경우, rawValue가 없다.
    //그 경우에는 자동으로 채워진다.
  
  var view: UIView { get } //해당 스타일의 샘플을 보여줄 view
}

extension StyleGuideViewable {
  public static var styleName: String {
    return "\(Self.self)".camelCaseToSpacing()
    //helper method. camel String을 읽기 쉽도록 바꿔준다.
  }
  
  public var itemName: String {
    return self.rawValue.camelCaseToSpacing()
  }
}

//enum, protocol, extension을 잘 활용하는 것이 무엇보다 중요하다.
