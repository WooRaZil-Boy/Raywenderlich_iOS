//
//  SpacetimeColors.swift
//  SpacetimeUI
//
//  Created by 근성가이 on 2018. 5. 12..
//  Copyright © 2018년 RayWenderlich.com. All rights reserved.
//

import UIKit

public enum SpacetimeColor {
    //응용 프로그램에서 사용하려는 프레임워크의 코드는 public으로 선언되어야 가져올 수 있다.
    case
    navigationBarBackground,
    navigationBarContent,
    tabBarContent,
    success,
    failure,
    defaultText,
    buttonBackground,
    buttonText
    //• 실제 기본 색상보다는 색상의 용도로 이름을 나타내어 위치를 쉽게 알 수 있다.
    //• success, failure은 이미지, 버튼, 텍스트 등 여러 곳에서 사용할 수 있으므로 유형별로 구별하지 않는다.
    //• default의 경우, 접두사를 지정해 주는 것이 좋다.
    
    public var color: UIColor {
        //switch로 독립적이면서 알아보기 쉽게 color를 관리할 수 있다.
        switch self {
        case .navigationBarBackground, .tabBarContent:
            return UIColor.spc_from(r: 9, g: 51, b: 119)
        case .defaultText:
            return .darkText
        default:
            return .orange
        }
        //UIColor+RGB.swift 파일을 옮기면서 오류난 부분을 살펴보며 switch의 case를 업데이트 한다.
        //프레임워크 번들에 직접 색상을 추가할 수도 있지만, UIColor(:in :compatibleWith) 생성자를 사용해
        //제대로 로드되었는지 확인하고 통과해야 한다.
    }
}

//이 앱은 두 개의 탭으로 나눠져 있는데, 같거나 비슷한 요소들이 많이 있다(색, 폰트, placeholder 이미지 등).
//중복되는 이런 요소들을 하나로 묶어 UI 요소 프레임워크를 생성한다(SpacetimeUI).

//프레임워크를 생성할 때는 가장 간단한 것(여기서는 색상)부터 시작하는 것이 좋다.
//프레임워크의 swift 파일 생성 시, target이 프레임워크로 되어 있는지 확인할 것
