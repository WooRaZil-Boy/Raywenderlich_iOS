//
//  Walk+CoreDataProperties.swift
//  DogWalk
//
//  Created by 근성가이 on 2017. 1. 1..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import Foundation
import CoreData


extension Walk {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Walk> {
        return NSFetchRequest<Walk>(entityName: "Walk");
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var dog: Dog?

}
