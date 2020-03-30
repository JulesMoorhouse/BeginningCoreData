//
//  Device+CoreDataClass.swift
//  BeginningCoreData
//
//  Created by Julian Moorhouse on 28/03/2020.
//  Copyright © 2020 Mindwarp Consultancy Ltd. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Device)
public class Device: NSManagedObject {

    var deviceDescription: String {
      return "\(name) (\(deviceType))"
    }

}
