//
//  ImageAttachment+CoreDataProperties.swift
//  UnCloudNotes
//
//  Created by Bianca Hinova on 7/13/17.
//  Copyright © 2017 bb. All rights reserved.
//
//

import Foundation
import CoreData


extension ImageAttachment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageAttachment> {
        return NSFetchRequest<ImageAttachment>(entityName: "ImageAttachment")
    }

    @NSManaged public var caption: String?
    @NSManaged public var width: Float
    @NSManaged public var height: Float
    @NSManaged public var image: NSObject?
}
