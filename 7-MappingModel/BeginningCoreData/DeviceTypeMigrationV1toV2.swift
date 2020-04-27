//
//  DeviceTypeMigrationV1toV2.swift
//  BeginningCoreData
//
//  Created by Julian Moorhouse on 27/04/2020.
//  Copyright © 2020 Mindwarp Consultancy Ltd. All rights reserved.
//

import CoreData

class DeviceTypeMigrationV1toV2: NSEntityMigrationPolicy {
    
    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        
        try super.createDestinationInstances(forSource: sInstance, in: mapping, manager: manager)
        
        // create or look up the DeviceType
        var deviceTypeInstance: NSManagedObject!
        
        let deviceTypeName = sInstance.value(forKey: "deviceType") as! String
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DeviceType")
        fetchRequest.predicate = NSPredicate(format: "name == %@", deviceTypeName as CVarArg)
        let results = try manager.destinationContext.fetch(fetchRequest)
        
        if let resultInstance = results.last as? NSManagedObject {
            // found
            deviceTypeInstance = resultInstance
        } else {
            // created it ourselves
            let entity = NSEntityDescription.entity(forEntityName: "DeviceType", in: manager.destinationContext)!
            deviceTypeInstance = NSManagedObject(entity: entity, insertInto: manager.destinationContext)
            deviceTypeInstance.setValue(deviceTypeInstance, forKey: "name")
        }
        
        // get the destination Device
        let destResults = manager.destinationInstances(forEntityMappingName: mapping.name, sourceInstances: [sInstance])
        if let destinationDevice = destResults.last {
            destinationDevice.setValue(deviceTypeInstance, forKey: "deviceType")
        }
    }
}
