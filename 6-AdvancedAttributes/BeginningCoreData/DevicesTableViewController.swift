//
//  DevicesTableViewController.swift
//  BeginningCoreData
//
//  Created by Julian Moorhouse on 28/03/2020.
//  Copyright © 2020 Mindwarp Consultancy Ltd. All rights reserved.
//

import CoreData
import UIKit

@objcMembers
class DevicesTableViewController: UITableViewController {
    var coreDataStack: CoreDataStack!
    var devices = [Device]()

    var selectedPerson: Person?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let selectedPerson = self.selectedPerson {
            title = "\(selectedPerson.name)'s Devices"
        } else {
            title = "Devices"

            navigationItem.rightBarButtonItems = [
                UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addDevice(sender:))),
                UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(selectFilter(sender:))),
            ]
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        reloadData()
        // tbc tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ruDevice", for: indexPath)

        let device = devices[indexPath.row]
        
        cell.textLabel?.text = device.deviceDescription
        cell.detailTextLabel?.text = "(owner name goes here)"

        return cell
    }

//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let vc = storyboard?.instantiateViewController(withIdentifier: "DeviceDetail") as? DeviceDetailTableViewController {
//            let device = devices[indexPath.row]
//
//            vc.device = device
//            navigationController?.pushViewController(vc, animated: true)
//        }
//    }

    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
         // Return false if you do not want the specified item to be editable.
         return true
     }
     */

    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
         if editingStyle == .delete {
             // Delete the row from the data source
             tableView.deleteRows(at: [indexPath], with: .fade)
         } else if editingStyle == .insert {
             // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
         }
     }
     */

    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

     }
     */

    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
         // Return false if you do not want the item to be re-orderable.
         return true
     }
     */

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */

    func reloadData(predicate: NSPredicate? = nil) {
        if let selectedPerson = selectedPerson {
            if let personDevices = selectedPerson.devices.allObjects as? [Device] {
                devices = personDevices
            }
        } else {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Device")
            fetchRequest.predicate = predicate

            fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: "deviceType", ascending: true),
                NSSortDescriptor(key: "name", ascending: true),
            ]

            do {
                if let results = try coreDataStack.managedObjectContext.fetch(fetchRequest) as? [Device] {
                    devices = results
                }
            } catch {
                fatalError("There was an error fetching the list of devices!")
            }
        }
        
        tableView.reloadData()
    }

    func addDevice(sender: AnyObject?) {
        performSegue(withIdentifier: "deviceDetail", sender: self)
    }

    func selectFilter(sender: AnyObject?) {
        let sheet = UIAlertController(title: "Filter Options", message: nil, preferredStyle: .actionSheet)
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        sheet.addAction(UIAlertAction(title: "Show All", style: .default, handler: {
            (action) -> Void in
            self.reloadData()
        }))

        sheet.addAction(UIAlertAction(title: "Only Owned Devices", style: .default, handler: {
            (action) -> Void in
            self.reloadData(predicate: NSPredicate(format: "owner != nil"))
        }))
        
        sheet.addAction(UIAlertAction(title: "Only Phones", style: .default, handler: {
            (action) -> Void in
            self.reloadData(predicate: NSPredicate(format: "deviceType.name =[c] 'iphone'"))
        }))

        sheet.addAction(UIAlertAction(title: "Only Watches", style: .default, handler: {
            (action) -> Void in
            self.reloadData(predicate: NSPredicate(format: "deviceType.name =[c] 'watch'"))
        }))
        
        present(sheet, animated: true, completion: nil)
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if selectedPerson != nil && identifier == "deviceDetail" {
            return false
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? DeviceDetailTableViewController {
            dest.coreDataStack = coreDataStack

            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                let device = devices[selectedIndexPath.row]
                dest.pDevice = device
            }
        }
    }
}
