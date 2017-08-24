//
//  Note.swift
//  UnCloudNotes
//
//  Created by 근성가이 on 2017. 1. 3..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Note: NSManagedObject {
    @NSManaged var title: String
    @NSManaged var body: String
    @NSManaged var dateCreated: Date!
    @NSManaged var displayIndex: NSNumber!
    @NSManaged var attachments: Set<Attachment>? //Set이 기본.
    
//    @NSManaged var image: UIImage? //DataModel에서 Transformable 속성은 2진 비트를 포함한다. NSValueTransformer으로 2진 비트를 UIImage로 변환 후 사용할 수 있다. (ImageTransformer애서 변환)
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        dateCreated = Date()
    }
    
    var image: UIImage? { //이전 버전에서 image 프로퍼티를 사용했을 경우에도 호환성이 유지된다.
        let imageAttachment = latestAttachment as? ImageAttachment
        
        return imageAttachment?.image
    }
    
    var latestAttachment: Attachment? {
        guard let attachments = attachments, let startingAttachment = attachments.first else {
                return nil
        }
        
        return Array(attachments).reduce(startingAttachment) {
            $0.dateCreated.compare($1.dateCreated) == .orderedAscending ? $0 : $1
        }
    }
}
