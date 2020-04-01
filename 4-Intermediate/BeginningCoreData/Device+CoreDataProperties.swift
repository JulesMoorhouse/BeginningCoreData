//
//  Device+CoreDataProperties.swift
//  BeginningCoreData
//
//  Created by Julian Moorhouse on 30/03/2020.
//  Copyright © 2020 Mindwarp Consultancy Ltd. All rights reserved.
//
//

import Foundation
import CoreData


extension Device {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Device> {
        return NSFetchRequest<Device>(entityName: "Device")
    }

    @NSManaged public var deviceType: String
    @NSManaged public var name: String
    @NSManaged public var deviceID: String?
    @NSManaged public var purchaseDate: Date?
    @NSManaged public var owner: Person?

}
