//
//  DeviceDetailTableViewController.swift
//  BeginningCoreData
//
//  Created by Julian Moorhouse on 28/03/2020.
//  Copyright © 2020 Mindwarp Consultancy Ltd. All rights reserved.
//

import CoreData
import UIKit

@objcMembers
class DeviceDetailTableViewController: UITableViewController {
    var coreDataStack: CoreDataStack!
    var device: Device?

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var deviceTypeTextField: UITextField!
    @IBOutlet weak var deviceOwnerLabel: UILabel!
    @IBOutlet weak var deviceIdentifierTextField: UITextField!
    @IBOutlet weak var purchaseDateTextField: UITextField!

    private let datePicker = UIDatePicker()
    private var selectedDate: NSDate?
    private lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.timeStyle = DateFormatter.Style.none
        df.dateStyle = DateFormatter.Style.medium
        
        return df
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        datePicker.datePickerMode = .date
        purchaseDateTextField.inputView = datePicker
        
        title = "Detail"

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let device = self.device {
            print(device.name)
            
            nameTextField.text = device.name
            deviceTypeTextField.text = device.deviceType

            if let owner = device.owner {
                deviceOwnerLabel.text = "Device owner: \(owner.name)"
            } else {
                deviceOwnerLabel.text = "Set Device Owner"
            }
            
            if let purchaseDate = device.purchaseDate {
                selectedDate = purchaseDate as NSDate
                datePicker.date = purchaseDate
                purchaseDateTextField.text = dateFormatter.string(from: purchaseDate)

            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        if let device = device,
            let name = nameTextField.text,
            let deviceType = deviceTypeTextField.text,
            let deviceId = deviceIdentifierTextField.text {
            device.name = name
            device.deviceType = deviceType
            device.deviceID = deviceId
            device.purchaseDate = selectedDate as Date?
        } else if device == nil {
            if let name = nameTextField.text,
                let deviceType = deviceTypeTextField.text,
                let deviceId = deviceIdentifierTextField.text,
                let entity = NSEntityDescription.entity(forEntityName: "Device", in: coreDataStack.managedObjectContext),
                !name.isEmpty,
                !deviceType.isEmpty {
                device = Device(entity: entity, insertInto: coreDataStack.managedObjectContext)
                device?.name = name
                device?.deviceType = deviceType
                device?.deviceID = deviceId
                device?.purchaseDate = selectedDate! as Date
            }
        }
        
        coreDataStack.saveMainContext()
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 3
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ruDetail", for: indexPath)
//
//        if indexPath.row == 0 {
//            cell.textLabel?.text = "Device name"
//            cell.detailTextLabel?.text = device?.name
//        } else if indexPath.row == 1 {
//            cell.textLabel?.text = "Device type"
//            cell.detailTextLabel?.text = device?.deviceType
//        } else if indexPath.row == 2 {
//            cell.textLabel?.text = "Device Owner"
//            cell.detailTextLabel?.text = "?"
//        }
//
//        return cell
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0, indexPath.row == 4 {
            if let personPicker = storyboard?.instantiateViewController(identifier: "People") as? PeopleTableViewController {
                // more personPicker setup code here
                personPicker.pickerDelegate = self
                personPicker.selectedPerson = device?.owner
                personPicker.coreDataStack = coreDataStack
                
                navigationController?.pushViewController(personPicker, animated: true)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func datePickerValueChanged(datePicker: UIDatePicker) {
        purchaseDateTextField.text = dateFormatter.string(from: datePicker.date)
        selectedDate = dateFormatter.date(from: purchaseDateTextField.text!) as NSDate?
    }
    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}

extension DeviceDetailTableViewController: PersonPickerDelegate {
    func didSelectPerson(person: Person) {
        device?.owner = person
        
        coreDataStack.saveMainContext()
    }
}
