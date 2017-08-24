//
//  AttachmentToImageAttachmentMigrationPolicyV3toV4.swift
//  UnCloudNotes
//
//  Created by 근성가이 on 2017. 1. 3..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import Foundation
import UIKit
import CoreData

let errorDomain = "Migration"

class AttachmentToImageAttachmentMigrationPolicyV3toV4: NSEntityMigrationPolicy { //FUCTION 표현식 이상으로 처리할 때
    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        let description = NSEntityDescription.entity(forEntityName: "ImageAttachment", in: manager.destinationContext)
        let newAttachment = ImageAttachment(entity: description!, insertInto: manager.destinationContext)
        
        func traversePropertyMappings(block: (NSPropertyMapping, String) -> ()) throws { //반복해서 매핑 작업 수행
            if let attributeMappings = mapping.attributeMappings{
                for propertyMapping in attributeMappings {
                    if let destinationName = propertyMapping.name {
                        block(propertyMapping, destinationName)
                    } else {
                        let message = "Attribute destination not configured properly"
                        let userInfo = [NSLocalizedFailureReasonErrorKey: message]
                        throw NSError(domain: errorDomain, code: 0, userInfo: userInfo) //오류 발생
                    }
                }
            } else {
                let message = "No Attribute Mappings found!"
                let userInfo = [NSLocalizedFailureReasonErrorKey: message]
                throw NSError(domain: errorDomain, code: 0, userInfo: userInfo)
            }
        }
        
        try traversePropertyMappings { propertyMapping, destinationName in
            if let valueExpression = propertyMapping.valueExpression {
                let context: NSMutableDictionary = ["source": sInstance]
                
                guard let destinationValue = valueExpression.expressionValue(with: sInstance, context: context) else {
                    return
                }
                
                newAttachment.setValue(destinationValue, forKey: destinationName)
            }
        }
        
        if let image = sInstance.value(forKey: "image") as? UIImage {
            newAttachment.setValue(image.size.width, forKey: "width")
            newAttachment.setValue(image.size.height, forKey: "height")
        }
        
        let body = sInstance.value(forKey: "note.body") as? NSString ?? ""
        newAttachment.setValue(body.substring(to: 80), forKey: "caption")
        
        manager.associate(sourceInstance: sInstance, withDestinationInstance: newAttachment, for: mapping)
    }
}
