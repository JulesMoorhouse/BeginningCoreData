//
//  DeviceType+CoreDataProperties.swift
//  BeginningCoreData
//
//  Created by Julian Moorhouse on 27/04/2020.
//  Copyright © 2020 Mindwarp Consultancy Ltd. All rights reserved.
//
//

import Foundation
import CoreData


extension DeviceType {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DeviceType> {
        return NSFetchRequest<DeviceType>(entityName: "DeviceType")
    }

    @NSManaged public var name: String
    @NSManaged public var devices: Device

}
