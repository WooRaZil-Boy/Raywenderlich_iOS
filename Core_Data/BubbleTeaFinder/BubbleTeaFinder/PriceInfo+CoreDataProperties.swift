//
//  PriceInfo+CoreDataProperties.swift
//  BubbleTeaFinder
//
//  Created by 근성가이 on 2017. 1. 1..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import Foundation
import CoreData


extension PriceInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PriceInfo> {
        return NSFetchRequest<PriceInfo>(entityName: "PriceInfo");
    }

    @NSManaged public var priceCategory: String?
    @NSManaged public var venue: Venue?

}
