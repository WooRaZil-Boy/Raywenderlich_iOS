//
//  EmployeePicture.swift
//  EmployeeDirectory
//
//  Created by 근성가이 on 2017. 1. 4..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import Foundation
import CoreData

class EmployeePicture: NSManagedObject {
    @NSManaged var picture: Data
    @NSManaged var employee: EmployeeDirectory.Employee //relationship
}
