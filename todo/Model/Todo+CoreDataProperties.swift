//
//  Todo+CoreDataProperties.swift
//  todo
//
//  Created by Benjamin Nguyen on 9/1/20.
//  Copyright © 2020 Benjamin Nguyen. All rights reserved.
//
//

import Foundation
import CoreData


extension Todo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Todo> {
        return NSFetchRequest<Todo>(entityName: "Todo")
    }

    @NSManaged public var text: String?
    @NSManaged public var dtmCreated: Date?
    @NSManaged public var dtmCompleted: Date?
    @NSManaged public var blnCompleted: Bool
    @NSManaged public var dtmDue: Date?
    @NSManaged public var blnStarred: Bool
}
