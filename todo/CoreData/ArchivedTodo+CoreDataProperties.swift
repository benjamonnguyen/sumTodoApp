//
//  ArchivedTodo+CoreDataProperties.swift
//  
//
//  Created by Benjamin Nguyen on 9/13/20.
//
//

import Foundation
import CoreData


extension ArchivedTodo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ArchivedTodo> {
        return NSFetchRequest<ArchivedTodo>(entityName: "ArchivedTodo")
    }

    @NSManaged public var text: String?
    @NSManaged public var dtmCreated: Date?
    @NSManaged public var dtmCompleted: Date?
    @NSManaged public var dtmDue: Date?
    @NSManaged public var blnStarred: Bool
    
}
