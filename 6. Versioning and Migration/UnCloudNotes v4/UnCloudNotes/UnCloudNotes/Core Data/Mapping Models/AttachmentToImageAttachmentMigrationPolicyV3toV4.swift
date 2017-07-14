//
//  AttachmentToImageAttachmentMigrationPolicyV3toV4.swift
//  UnCloudNotes
//
//  Created by Bianca Hinova on 7/13/17.
//  Copyright © 2017 bb. All rights reserved.
//

import CoreData
import UIKit

class AttachmentToImageAttachmentMigrationPolicyV3toV4: NSEntityMigrationPolicy {
    
    
    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        
        let newAttachment = NSEntityDescription.insertNewObject(forEntityName: "ImageAttachment", into: manager.destinationContext)
        
        
        func traveresePropertyMappings(block: (NSPropertyMapping) -> ()) throws {
            if let attributeMappings = mapping.attributeMappings {
                for propertyMapping in attributeMappings {
                    if propertyMapping.name != nil {
                        block(propertyMapping)
                    } else {
                        let message = "Attribute destination not configured"
                        let userInfo = [NSLocalizedFailureReasonErrorKey : message]
                        throw NSError(domain: "AttachmentToImageAttachment_ERROR_DOMAIN", code: 0, userInfo: userInfo)
                    }
                }
            } else {
                let message = "No Attribute Mapping Found"
                let userInfo = [NSLocalizedFailureReasonErrorKey : message]
                throw NSError(domain: "AttachmentToImageAttachment_ERROR_DOMAIN", code: 0, userInfo: userInfo)
            }
        }
        
        do {
            try traveresePropertyMappings { propertyMapping in
                if let valueExpression = propertyMapping.valueExpression {
                    let context: NSMutableDictionary = ["source":sInstance]
                    let destinationValue: Any? = valueExpression.expressionValue(with: sInstance, context: context)
                    newAttachment.setValue(destinationValue, forKey: propertyMapping.name!)
                }
                
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        if let image = sInstance.value(forKey: "image") as? UIImage {
            newAttachment.setValue(image.size.width, forKey: "width")
            newAttachment.setValue(image.size.height, forKey: "height")
        }
        
        if let body = sInstance.value(forKeyPath: "note.body") as? String {
            let substringLenght = body.characters.count < 80 ? body.characters.count : 80
            let nsBodyString = body as NSString
            newAttachment.setValue(nsBodyString.substring(to: substringLenght), forKey: "caption")
        }
        
        manager.associate(sourceInstance: sInstance, withDestinationInstance: newAttachment, for: mapping)
    }
}
