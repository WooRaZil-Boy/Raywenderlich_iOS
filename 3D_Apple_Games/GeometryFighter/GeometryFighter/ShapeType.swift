//
//  ShapeType.swift
//  GeometryFighter
//
//  Created by 근성가이 on 2018. 9. 12..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import Foundation

enum ShapeType: Int {
    //게임에서 사용할 다양한 모양의 ShapeType
    case box = 0
    case sphere
    case pyramid
    case torus
    case capsule
    case cylinder
    case cone
    case tube
    
    static func random() -> ShapeType { //임의의 ShapeType 생성
        let maxValue = tube.rawValue
        let rand = arc4random_uniform(UInt32(maxValue+1))
        
        return ShapeType(rawValue: Int(rand))!
    }
}

