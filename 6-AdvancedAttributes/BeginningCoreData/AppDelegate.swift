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
    lazy var coreDataStack = CoreDataStack()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Pass coreDataStack down the view stack
        if let tab = window?.rootViewController as? UITabBarController {
            for child in tab.viewControllers! {
                if let child = child as? UINavigationController, let top = child.topViewController {
                    let sel = Selector.init(("coreDataStack"))
                    if top.responds(to: (sel)) {
                        top.setValue(coreDataStack, forKey: "coreDataStack")
                    }
                }
            }
        }

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Device")

        do {
            let results = try coreDataStack.managedObjectContext.fetch(fetchRequest)
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
        coreDataStack.saveMainContext()
    }

    func addTestData() {

        guard let entity = NSEntityDescription.entity(forEntityName: "Device", in: coreDataStack.managedObjectContext),
            let personEntity = NSEntityDescription.entity(forEntityName: "Person", in: coreDataStack.managedObjectContext),
            let deviceTypeEntity = NSEntityDescription.entity(forEntityName: "DeviceType", in: coreDataStack.managedObjectContext) else {
          fatalError("Could not find entity descriptions!")
        }
        
        let phoneDeviceType = DeviceType(entity: deviceTypeEntity, insertInto: coreDataStack.managedObjectContext)
        phoneDeviceType.name = "iPhone"
        let watchDeviceType = DeviceType(entity: deviceTypeEntity, insertInto: coreDataStack.managedObjectContext)
        watchDeviceType.name = "Watch"
        
        for i in 1...25 {
            // Create an instance of the managed object and set properties into the context
            let device = Device(entity: entity, insertInto: coreDataStack.managedObjectContext)

            // Add test data values
            device.name = "Some Device #\(i)"
            device.deviceType = (i % 3 == 0) ? watchDeviceType : phoneDeviceType
        }


        let bob = Person(entity: personEntity, insertInto: coreDataStack.managedObjectContext)
        bob.name = "Bob"
        let jane = Person(entity: personEntity, insertInto: coreDataStack.managedObjectContext)
        jane.name = "Jane"

        coreDataStack.saveMainContext()
    }
}
