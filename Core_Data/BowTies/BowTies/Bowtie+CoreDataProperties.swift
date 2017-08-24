//
//  Bowtie+CoreDataProperties.swift
//  BowTies
//
//  Created by 근성가이 on 2016. 12. 22..
//  Copyright © 2016년 근성가이. All rights reserved.
//

import Foundation
import CoreData


extension Bowtie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bowtie> { ////@NSManaged은 Objective-C에서 @dynamic처럼 컴파일러에게 러닝타임 때 속성의 구현 됨을 알려 준다. //보통 프로퍼티들은 컴파일 시 값을 할당하지만, CoreData는 컴파일 시 프로퍼티의 값의 원본을 알 수 없다.
        return NSFetchRequest<Bowtie>(entityName: "Bowtie");
    }

    @NSManaged public var isFavorite: Bool
    @NSManaged public var lastWorn: NSDate?
    @NSManaged public var name: String?
    @NSManaged public var photoData: NSData?
    @NSManaged public var rating: Double
    @NSManaged public var searchKey: String?
    @NSManaged public var timesWorn: Int32
    @NSManaged public var tintColor: NSObject?

}
