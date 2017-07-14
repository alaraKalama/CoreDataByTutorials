//
//  Attachment+CoreDataProperties.swift
//  UnCloudNotes
//
//  Created by Bianca Hinova on 7/13/17.
//  Copyright © 2017 bb. All rights reserved.
//
//

import Foundation
import CoreData


extension Attachment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Attachment> {
        return NSFetchRequest<Attachment>(entityName: "Attachment")
    }

    @NSManaged public var dateCreated: NSDate?
    @NSManaged public var image: NSObject?
    @NSManaged public var note: Note?

}
