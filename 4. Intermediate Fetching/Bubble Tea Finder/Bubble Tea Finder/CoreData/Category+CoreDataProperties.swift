//
//  Category+CoreDataProperties.swift
//  Bubble Tea Finder
//
//  Created by Bianca Hinova on 7/7/17.
//  Copyright © 2017 bb. All rights reserved.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var name: String?
    @NSManaged public var id: String?
    @NSManaged public var venue: Venue?

}
