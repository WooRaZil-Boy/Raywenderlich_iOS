//
//  Location+CoreDataClass.swift
//  MyLocations
//
//  Created by 근성가이 on 2018. 2. 20..
//  Copyright © 2018년 근성가이. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit

@objc(Location) //@objc의 속성 일부분
//스위프트 컴파일러는 name managling 매커니즘으로 메서드 내부 이름을 변경하여 고유하게 식별한다.
//각 메서드를 고유하게 식별하여 모든 메서드 호출을 해결할 수 있도록.
//Swift 코드만 있는 경우에는 문제 없지만, Objective-C 코드를 하이브리드로 쓰는 경우, 변환으로 인해 Swift 클래스를 올바르게 식별할 수 없는 경우가 생긴다.
//따라서 @objc(Location)라는 표기법으로 Objective-C가 특정 클래스를 참조하는 데 사용하는 이름이라는 것을 컴파일러에 알려준다.
//이 프로젝트에서는 Swift 코드만 쓰므로 문제가 일어나지는 않는다.

public class Location: NSManagedObject, MKAnnotation { //NSManagedObject Core Data에 의해 관리되는 모든 객체의 기본 클래스이다.
    //일반 객체는 NSObject을 상속하지만, Core Data 객체는 NSManagedObject를 상속한다.
    
    //맵 뷰에서 활용할 수 있도록 MKAnnotation를 추가한다. //coordinate, title, subtitle를 구현해야 한다.
    //MKAnnotation에서 위의 세 속성은 public으로 선언해야 한다.
    public var coordinate: CLLocationCoordinate2D { //MKAnnotation //computed property //read-only
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    public var title: String? { //MKAnnotation //computed property //read-only
        if locationDescription.isEmpty {
            return "(No Description)"
        } else {
            return locationDescription
        }
    }
    
    //get{}, set{newValue}을 모두 구현하면 computed property에서도 읽고 쓰기가 가능하다.
    //get{}만 구현하면 read-only. 이 경우에는 get 키워드를 생략해서 쓸 수 있다.
    //computed property 대신 메서드를 사용하기도 한다.
//    func title() -> String? {
//        if locationDescription.isEmpty {
//            return "(No Description)"
//        } else {
//            return locationDescription
//        }
//    }
    
    public var subtitle: String? { //MKAnnotation //computed property //read-only
        return category
    }
}

//스키마를 추가해 SQL을 볼 수도 있다. p.637
//-com.apple.CoreData.SQLDebug 1
//-com.apple.CoreData.Logging.stderr 1
