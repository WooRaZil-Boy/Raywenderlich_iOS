//
//  ImageAttachment.swift
//  UnCloudNotes
//
//  Created by 근성가이 on 2017. 1. 3..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import CoreData

class ImageAttachment: Attachment {
    @NSManaged var image: UIImage?
    @NSManaged var width: Float
    @NSManaged var height: Float
    @NSManaged var caption: String
}
