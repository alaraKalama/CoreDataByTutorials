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

}
