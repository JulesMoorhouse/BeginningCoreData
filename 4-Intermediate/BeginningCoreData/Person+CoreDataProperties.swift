//
//  Person+CoreDataProperties.swift
//  BeginningCoreData
//
//  Created by Julian Moorhouse on 29/03/2020.
//  Copyright © 2020 Mindwarp Consultancy Ltd. All rights reserved.
//
//

import Foundation
import CoreData


extension Person {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person")
    }

    @NSManaged public var name: String
    @NSManaged public var devices: NSSet?

}

// MARK: Generated accessors for devices
extension Person {

    @objc(addDevicesObject:)
    @NSManaged public func addToDevices(_ value: Device)

    @objc(removeDevicesObject:)
    @NSManaged public func removeFromDevices(_ value: Device)

    @objc(addDevices:)
    @NSManaged public func addToDevices(_ values: NSSet)

    @objc(removeDevices:)
    @NSManaged public func removeFromDevices(_ values: NSSet)

}
