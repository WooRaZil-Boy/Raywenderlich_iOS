//
//  GradientView.swift
//  StoreSearch
//
//  Created by 근성가이 on 2016. 12. 15..
//  Copyright © 2016년 근성가이. All rights reserved.
//

import UIKit

class GradientView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        autoresizingMask = [.flexibleWidth, .flexibleHeight] //오토 리사이징 //오토 레이아웃 대신 간단히 적용 //부모뷰와 똑같은 크기를 가지게 된다.
    }
    
    required init?(coder aDecoder: NSCoder) { //실제 여기서는 사용되지 않지만, UIVIew는 항상 init?(coder)를 구현하도록 강제한다. required!
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
        autoresizingMask = [.flexibleWidth, .flexibleHeight] //오토 리사이징 //오토 레이아웃 대신 간단히 적용 //부모뷰와 똑같은 크기를 가지게 된다
    }
}

extension GradientView {
    override func draw(_ rect: CGRect) { //일반적으로 그라디언트와 같이 draw () 메서드 내에서 새 객체를 만드는 것이 바람직하지 않습니다. 특히 draw ()가 자주 호출되는 경우에 특히 그렇습니다. 이 경우 처음으로 개체를 만들 때와 같은 인스턴스를 반복해서 사용하는 것이 좋습니다 - lazy로 //하지만 여기에선 한 번만 호출되므로.
        let components: [CGFloat] = [ 0, 0, 0, 0.3, 0, 0, 0, 0.7 ] //color stops. //위치 1 = (0, 0, 0, 0.3) = 검은색 알파 0.3 //위치 2 = (0, 0, 0, 0.7) 검은색 알파 0.7
        let locations: [CGFloat] = [ 0, 1 ] //백분율 0%, 100%. 색상 배치할 위치의 백분율?
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: locations, count: 2)
        
        let x = bounds.midX
        let y = bounds.midY
        let centerPoint = CGPoint(x: x, y: y)
        let radius = max(x, y)
        
        let context = UIGraphicsGetCurrentContext() //그림을 그리려면 UIView 객체를 설정하고 drawRect: 메서드를 구현해야 한다. view 객체는 drawRect: 메서드를 호출하기 전에 드로잉 환경을 자동으로 구성해 놓는다. 따라서 아이폰에서는 바로 그리기를 시작할 수 있다. 자동으로 만들어진 그래픽스 컨텍스트를 얻기 위해서 UIKit 함수인 UIGraphicsGetCurrentContext 함수를 호출한다. //항상 CoreGraphic은 context가 있어야 그릴 수 있다.
        context?.drawRadialGradient(gradient!, startCenter: centerPoint, startRadius: 0, endCenter: centerPoint, endRadius: radius, options: .drawsAfterEndLocation)
    }
}
