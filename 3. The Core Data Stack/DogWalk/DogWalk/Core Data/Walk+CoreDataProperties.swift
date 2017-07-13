//
//  Walk+CoreDataProperties.swift
//  DogWalk
//
//  Created by Bianca Hinova on 7/6/17.
//  Copyright © 2017 bb. All rights reserved.
//
//

import Foundation
import CoreData


extension Walk {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Walk> {
        return NSFetchRequest<Walk>(entityName: "Walk")
    }

    @NSManaged public var time: NSDate?
    @NSManaged public var dog: Dog?

}
