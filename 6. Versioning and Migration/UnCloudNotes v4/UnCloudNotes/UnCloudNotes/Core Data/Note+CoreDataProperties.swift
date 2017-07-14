//
//  Note+CoreDataProperties.swift
//  UnCloudNotes
//
//  Created by Bianca Hinova on 7/13/17.
//  Copyright © 2017 bb. All rights reserved.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func notesFetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var body: String?
    @NSManaged public var dateCreated: NSDate?
    @NSManaged public var title: String?
    @NSManaged public var displayIndex: Int64
    @NSManaged public var attachments: NSSet
    
    var image: NSObject? {
        return self.latestAttachment?.image
    }
    
    private var latestAttachment: ImageAttachment? {
        if self.attachments.count == 0 {
            return nil
        }
        
        let attachmentsToSort = self.attachments.allObjects
            .map { $0 as! ImageAttachment }
            .filter { $0 != nil }
            .map { $0! }
            .sorted {
                let date1 = $0.dateCreated?.timeIntervalSinceReferenceDate
                let date2 = $1.dateCreated?.timeIntervalSinceReferenceDate
                return date1! > date2!
        }
        
        return attachmentsToSort.first
    }
}
