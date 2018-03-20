//
//  EmployeePicture.swift
//  EmployeeDirectory
//
//  Created by 근성가이 on 2018. 3. 20..
//  Copyright © 2018년 Razeware. All rights reserved.
//

import Foundation
import CoreData

public class EmployeePicture: NSManagedObject {

}

extension EmployeePicture {
  @nonobjc public class func fetchRequest() -> NSFetchRequest<EmployeePicture> {
    //Swift 코드가 Objective-C와 연결될 때, @nonobjc 키워드가 붙은 속성과 메서드는 노출되지 않는다.
    return NSFetchRequest<EmployeePicture>(entityName: "EmployeePicture")
  }
  
  @NSManaged public var picture: Data?
  @NSManaged public var employee: Employee?
}

//직접 만들지 않고 Editor\Create NSManagedObject Subclass... 로 생성할 수도 있다.
//Objective-C bridging header는 생성하지 않는다.
