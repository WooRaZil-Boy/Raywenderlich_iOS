//
//  SpacetimeLabels.swift
//  SpacetimeUI
//
//  Created by 근성가이 on 2018. 5. 12..
//  Copyright © 2018년 RayWenderlich.com. All rights reserved.
//

import UIKit

enum SpacetimeLabelStyle {
    //스타일이 하나 밖에 없지만, 추후 확장 가능성을 위해 열거형으로 설정하는 것이 좋다.
    case
    cellTitle
    
    var textColor: SpacetimeColor {
        //switch로 각 상황에 맞춘 색상을 반환한다. 여기서는 시간 절약을 위해 default로
        return .defaultText
    }
    
    private var fontType: SpacetimeFont {
        //font를 생성하기 위해 내부에서 사용하는 속성이므로 private로 선언한다.
        //switch로 각 상황에 맞춘 폰트를 반환한다. 여기서는 시간 절약을 위해 bold로
        return .bold
    }
    
    private var fontSize: SpacetimeFontSize {
        //font를 생성하기 위해 내부에서 사용하는 속성이므로 private로 선언한다.
        //switch로 각 상황에 맞춘 폰트 크기를 반환한다. 여기서는 시간 절약을 위해 normal로
        return .normal
    }
    
    var font: UIFont {
        //fontType과 fontSize로 해당 폰트를 만들어 낸다. 따라서 열거형 없이 단순히 반환할 수 있다.
        return self.fontType.of(size: self.fontSize)
    }
}
//스타일 설정에는 폰트와 색상이 있다. 이전과 같이 간단한 것(색상)부터 시작하는 것이 좋다.




public class SpacetimeBaseLabel: UILabel {
    var labelStyle: SpacetimeLabelStyle! {
        didSet { //스타일이 설정되면 레이블의 폰트와 색상을 지정해 준다.
            self.font = labelStyle.font
            self.textColor = labelStyle.textColor.color
        }
    }
}

public class CellTitleLabel: SpacetimeBaseLabel {
    public required init?(coder aDecoder: NSCoder) {
        //스토리보드에서 생성될 때 호출
        super.init(coder: aDecoder)
        self.labelStyle = .cellTitle
    }
}
