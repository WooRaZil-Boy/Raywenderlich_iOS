//
//  JournalEntry.swift
//  SurfJournal
//
//  Created by 근성가이 on 2017. 1. 5..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import Foundation
import CoreData

class JournalEntry: NSManagedObject {
    @NSManaged var date: Date?
    @NSManaged var height: String?
    @NSManaged var period: String?
    @NSManaged var wind: String?
    @NSManaged var location: String?
    @NSManaged var rating: NSNumber?
}
