//
//  AppDelegate.swift
//  BeginningCoreData
//
//  Created by Julian Moorhouse on 26/03/2020.
//  Copyright © 2020 Mindwarp Consultancy Ltd. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        addTestData()
        
        // Instantiate fetch request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Device")
        let managedObjectContext = persistentContainer.viewContext
        
        do {
            // Get optional array and cast to managed object
            if let results = try managedObjectContext.fetch(fetchRequest) as? [NSManagedObject] {
                // Iterate unordered list of results
                for result in results {
                    if let deviceType = result.value(forKey: "deviceType") as? String, let name = result.value(forKey: "name") as? String {
                        print("Got \(deviceType) name = \(name)")
                    }
                }
            }
        } catch {
            print("There was a fetch error!")
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "BeginningCoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func addTestData() {
        let managedObjectContext = persistentContainer.viewContext

        // Reference to Core Data Device entity
        guard let entity =
            NSEntityDescription.entity(forEntityName: "Device", in: managedObjectContext) else {
                fatalError("Could not find entry description!")
        }
        
        for i in 1...25 {
            // Create an instance of the managed object and set properties into the context
            let device = NSManagedObject(entity: entity, insertInto: managedObjectContext)
            
            // Add test data values
            device.setValue("Some Device #\(i)", forKey: "name")
            device.setValue(i % 3 == 0 ? "Watch" : "iPhone", forKey: "deviceType")
        }
        
        //Test data is not saved, just kept in memory.
    }
}

