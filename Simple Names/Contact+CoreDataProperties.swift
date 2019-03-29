//
//  Contact+CoreDataProperties.swift
//  Simple Names
//
//  Created by Ruslan Arhypenko on 3/29/19.
//  Copyright © 2019 Ruslan Arhypenko. All rights reserved.
//
//

import Foundation
import CoreData


extension Contact {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Contact> {
        return NSFetchRequest<Contact>(entityName: "Contact")
    }

    @NSManaged public var name: String?
    @NSManaged public var email: String?
    @NSManaged public var id: Int64
    @NSManaged public var isManuallyCreated: Bool

}
