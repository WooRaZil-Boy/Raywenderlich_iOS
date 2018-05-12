//
//  UIFont+Spacetime.swift
//  Spacetime
//
//  Created by Ellen Shapiro on 1/7/18.
//  Copyright © 2018 RayWenderlich.com. All rights reserved.
//

import UIKit

/**
 Good resource for fonts and their font names available on iOS:
 http://iosfonts.com/
 */
public enum SpacetimeFont: String, StyleGuideViewable {
    //아래에서 글꼴의 크기를 제한한 것처럼, 글꼴 유형에 대한 제한도 할 수 있다.
  case
  standard,
  condensed,
  bold,
  condensedBold
  
  public func of(size: SpacetimeFontSize) -> UIFont {
    //프레임워크의 메서드는 pulic으로 선언해야 다른 응용 프로그램에서 사용할 수 있다.
    switch self {
    case .standard:
      return UIFont(name: "Futura-Medium", size: size.value)!
    case .condensed:
      return UIFont(name: "Futura-CondensedMedium", size: size.value)!
    case .bold:
      return UIFont(name: "Futura-Bold", size: size.value)!
        //spc_bold를 대체
    case .condensedBold:
      return UIFont(name: "Futura-CondensedExtraBold", size: size.value)!
//    default:
//        return UIFont(name: "Chalkduster", size: size.value)!
//        //기본 값으로 전혀 다른 폰트를 주고, 잘못 코딩했을 때 쉽게 알 수 있다.
    }
  }
    
    public var view: UIView { //샘플 뷰에 해당 style을 적용한다.
        let label = UILabel()
        label.font = self.of(size: .normal)
        label.text = label.font.fontName
        
        return label
    }
}

public enum SpacetimeFontSize: String {
    //현재 글꼴을 설정하는 메서드들은 크기를 하드코딩해서 설정한다(직접 크기를 숫자로 지정함).
    //이 때 그 크기를 enum으로 분류해 놓으면 오타를 방지하고, 코드를 쉽게 관리할 수 있다.
  case
  tiny,
  small,
  medium,
  normal

  var value: CGFloat {
    //이 값은 내부에서만 사용되기 때문에 public이 아니어도 된다.
    switch self {
    case .tiny:
      return 10
    case .small:
      return 14
    case .medium:
      return 16
    case .normal:
      return 17
    }
  }
}

extension SpacetimeFontSize: StyleGuideViewable {
    public var view: UIView {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: self.value)
        label.text = "\(self.value) pt"
        return label
    }
}
//계속해서 protocol을 확장하면서 필요한 기능을 입력한다.
//이 경우, protocol 요구사항의 일부인 경우와 초기 선언의 일부인 경우를 구분해 주는 것이 더 적절하다.
//따라서 위에서, StyleGuideViewable를 떼어내어 따로 extension해 준다.
