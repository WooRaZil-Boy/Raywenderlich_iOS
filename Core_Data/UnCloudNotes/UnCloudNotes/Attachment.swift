//
//  Attachment.swift
//  UnCloudNotes
//
//  Created by 근성가이 on 2017. 1. 3..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Attachment: NSManagedObject {
    @NSManaged var dateCreated: Date
    @NSManaged var note: Note?
}
