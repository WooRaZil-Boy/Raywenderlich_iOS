//
//  Employee.swift
//  EmployeeDirectory
//
//  Created by 근성가이 on 2017. 1. 4..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import Foundation
import CoreData

class Employee: NSManagedObject {
    @NSManaged var startDate: Date
    @NSManaged var about: String
    @NSManaged var active: NSNumber
    @NSManaged var address: String
    @NSManaged var department: String
    @NSManaged var email: String
    @NSManaged var guid: String
    @NSManaged var name: String
    @NSManaged var phone: String
    @NSManaged var pictureThumbnail: Data
    @NSManaged var picture: EmployeeDirectory.EmployeePicture
    @NSManaged var vacationDays: NSNumber
    @NSManaged var sales: Set<Sale>
}
