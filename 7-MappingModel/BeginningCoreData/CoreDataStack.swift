//
//  CoreDataStack.swift
//  BeginningCoreData
//
//  Created by Julian Moorhouse on 30/03/2020.
//  Copyright © 2020 Mindwarp Consultancy Ltd. All rights reserved.
//

import CoreData
import Foundation

class CoreDataStack: NSObject {
    static let moduleName = "BeginningCoreData"
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // This resource is the same name as your xcdatamodeld contained in your project
        guard let modelURL =
            Bundle.main.url(forResource: CoreDataStack.moduleName, withExtension: "momd") else {
            fatalError("Error loading model from bundle")
        }

        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }

        return mom
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)

        let fileManager = FileManager.default

        guard let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            fatalError("Unable to resolve document directory")
        }

        let storeURL = docURL.appendingPathComponent("\(CoreDataStack.moduleName).sqlite")

        var failureReason = "There was an error creating or loading the application's saved data."

        do {
            let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: false]

            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                               configurationName: nil,
                                               at: storeURL,
                                               options: options)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain:
                "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)

            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        return coordinator
    }()

    private lazy var savedManagedObjectContext: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.persistentStoreCoordinator = self.persistentStoreCoordinator
        return moc
    } ()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = self.savedManagedObjectContext
        return context
    }()

    func saveMainContext() {
        guard managedObjectContext.hasChanges || savedManagedObjectContext.hasChanges else {
            return
        }
        
        managedObjectContext.performAndWait() {
            // Save synchronously
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Error saving main managed object context! \(nserror), \(nserror.userInfo)")
            }
            
            // Save asynchronously
            savedManagedObjectContext.perform() {
                do {
                    try self.savedManagedObjectContext.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Error saving private managed object context! \(nserror), \(nserror.userInfo)")
                }
            }
        }
        
        if managedObjectContext.hasChanges {

        }
    }
}
