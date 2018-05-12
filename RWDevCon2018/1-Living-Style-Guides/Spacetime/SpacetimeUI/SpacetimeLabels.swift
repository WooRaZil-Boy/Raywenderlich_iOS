//
//  SpacetimeLabels.swift
//  SpacetimeUI
//
//  Created by Ellen Shapiro on 3/25/18.
//  Copyright © 2018 RayWenderlich.com. All rights reserved.
//

import UIKit

public enum SpacetimeLabelStyle: String {
    //스타일이 하나 밖에 없더라도, 추후 확장 가능성을 위해 열거형으로 설정하는 것이 좋다.
  case
  calloutText,
  cellTitle,
  cellSubtitle,
  detailText,
  explanationText
  
  var textColor: SpacetimeColor {
    //switch로 각 상황에 맞춘 색상을 반환한다.
    switch self {
    case .calloutText,
         .cellSubtitle,
         .cellTitle,
         .detailText,
         .explanationText:
      return .defaultText
    }
  }
  
  private var fontType: SpacetimeFont {
    //font를 생성하기 위해 내부에서 사용하는 속성이므로 private로 선언한다.
    //switch로 각 상황에 맞춘 폰트를 반환한다.
    switch self {
    case .calloutText,
         .cellSubtitle,
         .detailText:
      return .condensed
    case .cellTitle:
      return .bold
    case .explanationText:
      return .standard
    }
  }
  
  private var fontSize: SpacetimeFontSize {
    //font를 생성하기 위해 내부에서 사용하는 속성이므로 private로 선언한다.
    //switch로 각 상황에 맞춘 폰트 크기를 반환한다.
    switch self {
    case .calloutText,
         .cellSubtitle,
         .cellTitle:
      return .normal
    case .detailText:
      return .small
    case .explanationText:
      return .medium
    }
  }
  
  var font: UIFont {
    //fontType과 fontSize로 해당 폰트를 만들어 낸다. 따라서 열거형 없이 단순히 반환할 수 있다.
    return self.fontType.of(size: self.fontSize)
  }
}
//스타일 설정에는 폰트와 색상이 있다. 이전과 같이 간단한 것(색상)부터 시작하는 것이 좋다.

extension SpacetimeLabelStyle: StyleGuideViewable {
    public var view: UIView {
        let label = SpacetimeBaseLabel()
        label.labelStyle = self
        label.numberOfLines = 0
        label.text =
        """
        Font: \(label.font.fontName)
        Size: \(label.font.pointSize) pt
        Color: \(self.textColor.itemName)
        """
        
        return label
    }
}

@IBDesignable
//CustomView를 만들었을 때, 그 View를 StoryBoard에서도 보고 싶을 때 선언한다.
//@IBInsepectable로 속성을 설정해 주면, 스토리보드에서 값을 할당해 줄 수 있다.
//http://gogorchg.tistory.com/entry/iOS-IBDesignable-IBInspectable-%ED%99%9C%EC%9A%A9
public class SpacetimeBaseLabel: UILabel {
  
  var labelStyle: SpacetimeLabelStyle! {
    didSet { //스타일이 설정되면 레이블의 폰트와 색상을 지정해 준다.
      self.font = labelStyle.font
      self.textColor = labelStyle.textColor.color
    }
  }
  
  func commonSetup() {
    // Code here will be executed in all setup states
  }
  
  convenience init() {
    self.init(frame: .zero)
  }
  
  override public init(frame: CGRect) {
    super.init(frame: frame)
    self.commonSetup()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    //스토리보드에서 생성될 때 호출
    super.init(coder: aDecoder)
    self.commonSetup()
  }
  
  override public func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    self.commonSetup()
  }
}

public class CellTitleLabel: SpacetimeBaseLabel {
  
  override func commonSetup() {
    self.labelStyle = .cellTitle
  }
}

public class ExplanationLabel: SpacetimeBaseLabel {
  
  override func commonSetup() {
    self.labelStyle = .explanationText
  }
}

public class CellSubtitleLabel: SpacetimeBaseLabel {
  
  override func commonSetup() {
    self.labelStyle = .cellSubtitle
  }
}

public class DetailLabel: SpacetimeBaseLabel {
  
  override func commonSetup() {
    self.labelStyle = .detailText
  }
}

public class CalloutLabel: SpacetimeBaseLabel {
  
  override func commonSetup() {
    self.labelStyle = .calloutText
  }
}
