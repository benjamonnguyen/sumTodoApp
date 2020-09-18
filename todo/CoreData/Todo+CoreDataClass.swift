//
//  Todo+CoreDataClass.swift
//  todo
//
//  Created by Benjamin Nguyen on 9/1/20.
//  Copyright © 2020 Benjamin Nguyen. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Todo)
public class Todo: NSManagedObject {
    convenience init(text:String, blnStarred:Bool, dtmCreated:Date, dtmCompleted:Date?, dtmDue:Date?, entity: NSEntityDescription, context: NSManagedObjectContext) {
        self.init(entity: entity, insertInto: context)
        self.text = text
        self.blnStarred = blnStarred
        self.dtmCreated = dtmCreated
        self.dtmCompleted = dtmCompleted
        self.dtmDue = dtmDue
    }
}
