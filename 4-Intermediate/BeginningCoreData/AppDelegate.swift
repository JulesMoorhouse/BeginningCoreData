//
//  AppDelegate.swift
//  BeginningCoreData
//
//  Created by Julian Moorhouse on 26/03/2020.
//  Copyright © 2020 Mindwarp Consultancy Ltd. All rights reserved.
//

import CoreData
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Pass managedObjectContext down the view stack
        if let tab = window?.rootViewController as? UITabBarController {
            for child in tab.viewControllers! {
                if let child = child as? UINavigationController, let top = child.topViewController {
                    if top.responds(to: #selector(setter: DeviceDetailTableViewController.managedObjectContext)) {
                        top.setValue(managedObjectContext, forKey: "managedObjectContext")
                    }
                }
            }
        }

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Device")

        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            // If no fetched records add test data
            if results.count == 0 {
                addTestData()
            }
        } catch {
            fatalError("Error fetching data!")
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - Core Data stack

    lazy var managedObjectModel: NSManagedObjectModel = {
        // This resource is the same name as your xcdatamodeld contained in your project
        guard let modelURL =
            Bundle.main.url(forResource: "BeginningCoreData", withExtension: "momd") else {
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
        
        let storeURL = docURL.appendingPathComponent("SingleViewCoreData.sqlite")

        var failureReason = "There was an error creating or loading the application's saved data."

        do {
            let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]

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

    lazy var managedObjectContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = self.persistentStoreCoordinator
        return context
    }()

    // MARK: - Core Data Saving support

    func saveContext() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func addTestData() {
        // Reference to Core Data Device entity
        guard let entity =
            NSEntityDescription.entity(forEntityName: "Device", in: managedObjectContext) else {
            fatalError("Could not find entry description!")
        }

        for i in 1...25 {
            // Create an instance of the managed object and set properties into the context
            let device = Device(entity: entity, insertInto: managedObjectContext)

            // Add test data values
            device.name = "Some Device #\(i)"
            device.deviceType = (i % 3 == 0) ? "Watch" : "iPhone"
        }

        guard let personEntity =
            NSEntityDescription.entity(forEntityName: "Person", in: managedObjectContext) else {
            fatalError("Could not find entry description!")
        }

        let bob = Person(entity: personEntity, insertInto: managedObjectContext)
        bob.name = "Bob"
        let jane = Person(entity: personEntity, insertInto: managedObjectContext)
        jane.name = "Jane"

        saveContext()
    }
}
