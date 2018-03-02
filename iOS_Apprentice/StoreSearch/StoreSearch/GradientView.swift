//
//  GradientView.swift
//  StoreSearch
//
//  Created by IndieCF on 2018. 3. 2..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit

class GradientView: UIView {
    override init(frame: CGRect) { //코드로 초기화
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) { //스토리보드, nib으로 초기화
        super.init(coder: aDecoder)
        
        backgroundColor = UIColor.clear
    } //스토리보드에서 생성되는 일이 없더라도 required이므로 구현해야 한다.
    
    override func draw(_ rect: CGRect) { //투명 배경(init) 위에 그라디언트를 그린다.
        //draw 메서드에서 객체를 생성하는 것은 좋지 않다. 처음 객체를 생성하고 동일한 인스턴스를 반복해 사용하는 것이 좋다(lazy).
        //하지만 여기에서는 DetailViewController가 로드될 때 한 번만 호출되므로 최적화 시킬 필요없다.
        let components: [CGFloat] = [0, 0, 0, 0.3, 0, 0, 0, 0.7] //색상 정지점
        //(0, 0, 0, 0.3) : 거의 투명한 검은색 alpha 0.3
        //(0, 0, 0, 0.7) : 약간 투명한 검은색 alpha 0.7
        let locations: [CGFloat] = [0, 1] //정지점들의 위치. //1이 100%. 원형에서는 원의 원주가 된다.
    
        let colorSpace = CGColorSpaceCreateDeviceRGB() //RGB 컬러 스페이스 //Gray, CMYK등을 사용할 수도 있다.
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: locations, count: 2) //색상 정지점과 위치를 이용해 그라디언트를 생성한다.
        //colorSpace : 색상 형식. 여기서는 RGB 형식으로
        //colorComponents : 그라디언트를 정의하는 색상 구성요소. 이 배열의 항목 수는 count와 colorSpace 구성 요소의 곱이어야 한다.
        //여기서는 colorSpace가 RGBA이므로 구성요소 4 * count 2 = 8개가 되어야 한다.
        //location : 색상의 위치. location이 nil이면 Quartz가 색상을 0 ~ 1사이에 균등하게 배치한다
        //nil로 설정했을 경우, 첫 색상은 0, 마지막 색상은 1, 중간 색상은 간격을 나눠 위치 결정.
        //count : 위치 수
        
        let x = bounds.midX //x 중심
        let y = bounds.midY //y 중심
        let centerPoint = CGPoint(x: x, y: y) //뷰의 중심 //하드코딩할 필요없이 어느 크기의 디바이스든 중심이 된다.
        let radius = max(x, y) //뷰의 중심 x, y값 중 큰 값.
        
        let context = UIGraphicsGetCurrentContext() //Core Graphics 드로잉은 항상 그래픽 컨텍스트에서 실행된다.
        //컨텍스트에 대한 참조를 가져와야 드로잉을 할 수 있다.
        context?.drawRadialGradient(gradient!, startCenter: centerPoint, startRadius: 0, endCenter: centerPoint, endRadius: radius, options: .drawsAfterEndLocation)
        //drawRadialGradient로 원형 그라디언트를 그린다. //drawsAfterEndLocation : endRadius이후에도 색(endRadius의 색)을 그린다.
    }
}

//PhotoShop 등에서도 이미지를 만들어 낼 수 있다. 하지만, 이미지를 사용하면 앱 용량이 커지고, 화면 크기를 맞춰야 하는 등 문제가 생길 수 있다.

