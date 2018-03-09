//
//  Bowtie+CoreDataProperties.swift
//  Bow Ties
//
//  Created by 근성가이 on 2018. 3. 9..
//  Copyright © 2018년 Razeware. All rights reserved.
//
//

import Foundation
import CoreData


extension Bowtie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bowtie> {
        return NSFetchRequest<Bowtie>(entityName: "Bowtie")
    }
  //@NSManaged는 Objective-C의 @dynamic처럼 CoreData 데이터베이스와 연결하고, 속성 프로퍼티는 런타임에 이루어진다.
  //일반적인 패턴은 프로퍼티가 메모리 인스턴스에 백업되지만, @NSManaged는 컴파일 시 알 수 없다.

    @NSManaged public var name: String?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var lastWorn: NSDate?
    @NSManaged public var rating: Double
    @NSManaged public var searchKey: String?
    @NSManaged public var timesWorn: Int32
    @NSManaged public var id: UUID?
  //xcdatamodeld의 UUID 타입은 universally unique identifier의 약자로 고유한 정보 식별에 사용된다.
    @NSManaged public var url: URL?
  //URI 타입은 uniform resource identifier의 약자로 리소스의 이름을 지정하고 식별한다. 모든 URL은 URI이다.
    @NSManaged public var photoData: NSData?
  //Binary Data는 Blob 데이터를 직접 저장하는 타입. 이미지, PDF 등 이진수로 직렬화할 수 있는 모든 파일이 가능하다.
  //하지만 Binary Data로 저장하면 성능에 많은 악영향을 끼친다. 그래서 보통은 경로를 지정.
  //CoreData에서 자체적으로 최적화할 수 있다. Attributes Inspector에서 Allows External Storage 체크하면,
  //CoreData는 데이터를 데이터베이스에 직접 저장할지 URI로 저장할지 자동으로 판단해 결정한다.
  //이 속성은 오직 Binary Data에서만 설정할 수 있으며, 활성화되면 CoreData를 쿼리할 수 없다.
    @NSManaged public var tintColor: NSObject?
  //이 앱에서는 UIColor를 저장해야 하는데, RBG값을 각각 따로 저장해 3가지 속성으로 저장할 수도 있다.
  //하지만, NSCoding이 구현된 객체(UIColor)를 사용하고 타입을 Transformable로 지정해 구현할 수 있다.
  //NSCoding는 NSObject. Swift의 Codable과 혼동하지 말것.

}

//KVC의 단점은 오타가 날 수 있다는 것. 따라서 데이터 모델의 각 엔티티에 대한 NSManagedObject의 서브 클래스를 생성한다.
// 1. 이렇게 managed object를 생성하면, KVC 대신 프로퍼티로 접근하므로 오타를 줄이고, 코드 어시스턴스를 활용할 수 있다.
// 2. extension으로 확장하거나 기존 메서드를 재정의할 수 있다.
//수동으로 만들려면 p.45
