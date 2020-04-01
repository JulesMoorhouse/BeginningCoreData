//
//  DebugViewController.swift
//  BeginningCoreData
//
//  Created by Julian Moorhouse on 30/03/2020.
//  Copyright © 2020 Mindwarp Consultancy Ltd. All rights reserved.
//

import CoreData
import UIKit

@objcMembers
class DebugViewController: UIViewController {
    var coreDataStack: CoreDataStack!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Debug"
        
        // Do any additional setup after loading the view.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func unassignAllTapped(sender: AnyObject) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Device")
        fetchRequest.predicate = NSPredicate(format: "owner != nil") // fields are case sensitive
        
        do {
            if let results = try coreDataStack.managedObjectContext.fetch(fetchRequest) as? [Device] {
                for device in results {
                    device.owner = nil
                }
                
                coreDataStack.saveMainContext()
                
                let alert = UIAlertController(title: "Batch Update Succeeded", message: "\(results.count) devices unassigned.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        } catch {
            let alert = UIAlertController(title: "Batch Update Failed", message: "There was an error unassigning the devices.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func DeleteAllTapped(sender: AnyObject) {
        let deviceFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Device")
        let deviceDeleteRequest = NSBatchDeleteRequest(fetchRequest: deviceFetchRequest)
        deviceDeleteRequest.resultType = .resultTypeCount
        
        let personFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
        let personDeleteRequest = NSBatchDeleteRequest(fetchRequest: personFetchRequest)
        personDeleteRequest.resultType = .resultTypeCount
        
        do {
            let deviceResult = try coreDataStack.managedObjectContext.execute(deviceDeleteRequest) as! NSBatchDeleteResult
            let personResult = try coreDataStack.managedObjectContext.execute(personDeleteRequest) as! NSBatchDeleteResult

            let alert = UIAlertController(title: "Batch Delete Succeeded", message: "\(deviceResult.result!) device records and \(personResult.result!) person records deleted.", preferredStyle: .alert)
              alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
              present(alert, animated: true, completion: nil)
        } catch {
            let alert = UIAlertController(title: "Batch Delete Failed", message: "There was an error unassigning the batch delete.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
}
