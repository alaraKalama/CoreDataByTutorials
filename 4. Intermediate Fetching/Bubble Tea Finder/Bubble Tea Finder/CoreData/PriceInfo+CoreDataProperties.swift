//
//  PriceInfo+CoreDataProperties.swift
//  Bubble Tea Finder
//
//  Created by Bianca Hinova on 7/7/17.
//  Copyright © 2017 bb. All rights reserved.
//
//

import Foundation
import CoreData


extension PriceInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PriceInfo> {
        return NSFetchRequest<PriceInfo>(entityName: "PriceInfo")
    }

    @NSManaged public var category: String?
    @NSManaged public var venue: Venue?

}
