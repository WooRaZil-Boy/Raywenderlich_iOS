//
//  Location+CoreDataProperties.swift
//  MyLocations
//
//  Created by 근성가이 on 2018. 2. 20..
//  Copyright © 2018년 근성가이. All rights reserved.
//
//

import Foundation
import CoreData
import CoreLocation //자동으로 클래스를 만들게 되면, @NSManaged public var placemark: NSObject?가 되는데 원래 자료형으로 지정해 주기 위해

extension Location { //DataModel.xcdatamodeld에서 지정한 속성의 특성을 그대로 작성한다.
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> { //@nonobjc 특성은 @objc 키워드의 반대
        //Objective-C에서 클래스, 메서드, 속성을 사용할 수 없게 한다.
        return NSFetchRequest<Location>(entityName: "Location")
    }

    //기본적으로 Entity의 Attribute는 선택사항이므로 nil이 될 수 있다. 이런 제약 조건들도 포함시켜야 한다.(DataModel.xcdatamodeld)
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var date: Date //자동 생성하면 NSDate가 기본형이 되는데, Date로 바꿔준다.
    @NSManaged public var locationDescription: String //description은 NSObject의 메서드 이름이므로 locationDescription로 설정한다.
    //Core data managed object는 NSObject에서 파생되기 때문에 NSObject 메서드와 이름이 충돌하면 안 된다.
    @NSManaged public var category: String
    @NSManaged public var placemark: CLPlacemark?
    //Placemark는 CLPlacemark 객체인데, Core Data Model의 Type에서 지원하지 않는 유형이다.
    //이런 경우 NSCoding 프로토콜을 구현하는 클래스를 DataModel.xcdatamodeld에서는 Transformable 타입으로 지정하면 된다.
    //NSCoding은 Objective-C에서 쓰이며, Swift의 Codable 프로토콜과 동일하다. 이를 통해 인코딩, 디코딩할 수 있다.
    @NSManaged public var photoID: NSNumber?
    //이미지는 blob(Binary Large OBjects)로 CoreData에 저장할 수 있지만, 이런 큰 데이터는 Documents 디렉토리에 일반 파일로 저장하고 그 주소를 CoreData에 저장하는 것이 낫다.
    //Data Model에서는 Int32로 선언했지만 여기서는 NSNumber인 이유는 Objective-C 프레임워크 이므로 제한이 있다. NSNumber는 Objective-C의 number 객체 처리.
    //Swift는 NSNumber를 Int로 자동 변환한다.
    
    //@NSManaged 키워드는 Core Data가 런타임에 지정된 속성을 확인한다는 것을 의미한다.
    //이런 속성에 새 값을 입력하면, Core Data는 해당 값을 일반 인스턴스 변수 대신 데이터 저장소에 저장한다.
}

//코어 데이터는 관계형 테이블이 아니라 오브젝트를 저장하는 것에 관한 것이다.
//엔티티는 SQL의 테이블로 생각할 수 있다. //이 앱에서는 하나의 엔티티만 필요하지만 필요에 따라 다양한 엔티티를 생성해야 될 수도 있다.
//크기가 큰 항목(사진)은 blob으로 처리할 수 있지만, 일반적으로 크기가 큰 항목은 디렉토리에 개별적으로 저장하는 것이 낫다.
//Entity = object(class), Attribute= property로 생각하면 된다.

//엔티티에 대해 고유한 클래스를 꼭 만들 필요는 없지만, Xcode에서 손쉽게 만들 수 있다.
//Codegen 메뉴에서 Manual/None.
//Editor → Create NSManagedObject Subclass....
//Codegen 설정에서 자동으로 클래스가 만들어지도록 할 수 있다.(기본값)

//iOS에서 Core Data는 모든 데이터를 SQLite 데이터베이스에 저장한다.





