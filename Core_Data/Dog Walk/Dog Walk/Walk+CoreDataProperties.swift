//
//  Walk+CoreDataProperties.swift
//  Dog Walk
//
//  Created by 근성가이 on 2018. 3. 10..
//  Copyright © 2018년 Razeware. All rights reserved.
//
//

import Foundation
import CoreData


extension Walk {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Walk> {
        return NSFetchRequest<Walk>(entityName: "Walk")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var dog: Dog?
  //때때로 Xcode는 특정 클래스 대신 NSManagedObject 타입으로 속성을 만드는 경우가 있다.
  //NSManagedObject의 서브 클래스를 여러개 동시에 만드는 경우 그러는데, 직접 유형을 수정하거나 다시 생성해서 고칠 수 있다.

}
