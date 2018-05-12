//
//  SpacetimeColors.swift
//  SpacetimeUI
//
//  Created by Ellen Shapiro on 3/25/18.
//  Copyright © 2018 RayWenderlich.com. All rights reserved.
//

import UIKit

public enum SpacetimeColor: String, StyleGuideViewable {
    //응용 프로그램에서 사용하려는 프레임워크의 코드는 public으로 선언되어야 가져올 수 있다.
    
    //StyleGuideViewable프로토콜을 추가하면, string유형의 rawValue가 없다는 에러가 난다.
    //하지만, SpacetimeColor를 String 해당 속성을 손쉽게 추가할 수 있는 방법이 있다.
    //enum에 해당 속성을 추가할 필요 없이, String을 선언해 주기만 하면 된다.
    
    //StyleGuide에서 SpacetimeUI를 추가했지만, 제대로 추가되지 않아 라이브러리를 찾지 못해 빌드되지 않는 경우가 있다.
    //이런 경우에는 Edit Scheme를 선택하고 Buiild에서 해당 스키마(SpacetimeUI)를 추가해 주면 된다.
  case
  navigationBarBackground,
  navigationBarContent,
  tabBarContent,
  success,
  failure,
  defaultText,
  buttonBackground,
  buttonBorder,
  buttonText
    //• 실제 기본 색상보다는 색상의 용도로 이름을 나타내어 위치를 쉽게 알 수 있다.
    //• success, failure은 이미지, 버튼, 텍스트 등 여러 곳에서 사용할 수 있으므로 유형별로 구별하지 않는다.
    //• default의 경우, 접두사를 지정해 주는 것이 좋다.
  
  public var color: UIColor {
    //switch로 독립적이면서 알아보기 쉽게 color를 관리할 수 있다.
    switch self {
    case .navigationBarBackground,
         .tabBarContent,
         .buttonBorder:
      return UIColor.spc_from(r: 9, g: 51, b: 119)
    case .navigationBarContent,
         .buttonText:
      return .white
    case .success:
      return UIColor.spc_from(r: 3, g: 91, b: 18)
    case .failure:
      return UIColor.spc_from(r: 135, g: 20, b: 12)
    case .defaultText:
      return .darkText
    case .buttonBackground:
      return .black
    }
    //UIColor+RGB.swift 파일을 옮기면서 오류난 부분을 살펴보며 switch의 case를 업데이트 한다.
    //프레임워크 번들에 직접 색상을 추가할 수도 있지만, UIColor(:in :compatibleWith) 생성자를 사용해
    //제대로 로드되었는지 확인하고 통과해야 한다.
  }
    
    public var view: UIView { //샘플 뷰에 해당 style을 적용한다.
        let view = UIView()
        view.backgroundColor = self.color
        
        return view
    }
}

//이 앱은 두 개의 탭으로 나눠져 있는데, 같거나 비슷한 요소들이 많이 있다(색, 폰트, placeholder 이미지 등).
//중복되는 이런 요소들을 하나로 묶어 UI 요소 프레임워크를 생성한다(SpacetimeUI).

//프레임워크를 생성할 때는 가장 간단한 것(여기서는 색상)부터 시작하는 것이 좋다.
//프레임워크의 swift 파일 생성 시, target이 프레임워크로 되어 있는지 확인할 것
