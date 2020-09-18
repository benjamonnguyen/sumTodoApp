//
//  ArchivedTodo+CoreDataProperties.swift
//  todo
//
//  Created by Benjamin Nguyen on 9/18/20.
//  Copyright © 2020 Benjamin Nguyen. All rights reserved.
//
//

import Foundation
import CoreData


extension ArchivedTodo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ArchivedTodo> {
        return NSFetchRequest<ArchivedTodo>(entityName: "ArchivedTodo")
    }

    @NSManaged public var blnStarred: Bool
    @NSManaged public var dtmCompleted: Date?
    @NSManaged public var dtmCreated: Date?
    @NSManaged public var dtmDue: Date?
    @NSManaged public var text: String?

}

extension ArchivedTodo : Identifiable {

}
