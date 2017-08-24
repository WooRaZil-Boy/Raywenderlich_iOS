//
//  Location+CoreDataProperties.swift
//  MyLocations
//
//  Created by 근성가이 on 2016. 12. 1..
//  Copyright © 2016년 근성가이. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

extension Location {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location");
    }
    
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var date: Date
    @NSManaged var locationDescription: String
    @NSManaged var category: String
    @NSManaged var placemark: CLPlacemark?
    @NSManaged var photoID: NSNumber? //Objective-C에서 Int를 optional로 할 수 없다.
    
}
