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
extension UIFont {
  //프레임워크의 메서드는 pulic으로 선언해야 다른 응용 프로그램에서 사용할 수 있다.
  public static func spc_standard(size: CGFloat) -> UIFont {
    return UIFont(name: "Futura-Medium", size: size)!
  }
  
  public static func spc_consensed(size: CGFloat) -> UIFont {
    return UIFont(name: "Futura-CondensedMedium", size: size)!
  }
  
//  public static func spc_bold(size: SpacetimeFontSize) -> UIFont {
//    return UIFont(name: "Futura-Bold", size: size.value)!
//  }
  
  public static func spc_condensedBold(size: CGFloat) -> UIFont {
    return UIFont(name: "Futura-CondensedExtraBold", size: size)!
  }
}



public enum SpacetimeFontSize {
    //현재 글꼴을 설정하는 메서드들은 크기를 하드코딩해서 설정한다(직접 크기를 숫자로 지정함).
    //이 때 그 크기를 enum으로 분류해 놓으면 오타를 방지하고, 코드를 쉽게 관리할 수 있다.
    case
    tiny,
    medium,
    normal
    
    var value: CGFloat {
        //이 값은 내부에서만 사용되기 때문에 public이 아니어도 된다.
        switch self {
        case .tiny:
            return 10
        case .medium:
            return 16
        case .normal:
            return 17
        }
    }
}

public enum SpacetimeFont {
    //위에서 글꼴의 크기를 제한한 것처럼, 글꼴 유형에 대한 제한도 할 수 있다.
    case
    standard,
    condensed,
    bold,
    condensedBold
    
    public func of(size: SpacetimeFontSize) -> UIFont {
        switch self {
        case .bold:
            return UIFont(name: "Futura-Bold", size: size.value)!
            //spc_bold를 대체
        default:
            return UIFont(name: "Chalkduster", size: size.value)!
            //기본 값으로 전혀 다른 폰트를 주고, 잘못 코딩했을 때 쉽게 알 수 있다.
        }
    }
}



