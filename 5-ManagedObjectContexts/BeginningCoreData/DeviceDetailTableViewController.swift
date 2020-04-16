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
    var pDevice: Device?

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var deviceTypeTextField: UITextField!
    @IBOutlet weak var deviceOwnerLabel: UILabel!
    @IBOutlet weak var deviceIdentifierTextField: UITextField!
    @IBOutlet weak var purchaseDateTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!

    private let datePicker = UIDatePicker()
    private var selectedDate: NSDate?
    private lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.timeStyle = DateFormatter.Style.none
        df.dateStyle = DateFormatter.Style.medium
        
        return df
    }()
    
    private let deviceTypePicker = UIPickerView()
    private var deviceTypes = [DeviceType]()
    private var selectedDeviceType: DeviceType?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        datePicker.datePickerMode = .date
        purchaseDateTextField.inputView = datePicker
        
        title = "Detail"

        loadDeviceTypes()
        deviceTypePicker.delegate = self
        deviceTypePicker.dataSource = self
        deviceTypeTextField.inputView = deviceTypePicker
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let device = pDevice {
            print(device.name)
            
            nameTextField.text = device.name
            deviceTypeTextField.text = device.deviceType?.name
            deviceIdentifierTextField.text = device.deviceID
            imageView.image = device.image as? UIImage
            
            if let owner = device.owner {
                deviceOwnerLabel.text = "Device owner: \(owner.name)"
            } else {
                deviceOwnerLabel.text = "Set Device Owner"
            }
            
            if let purchaseDate = device.purchaseDate {
                selectedDate = purchaseDate as NSDate
                datePicker.date = purchaseDate
                purchaseDateTextField.text = dateFormatter.string(from: purchaseDate)

                coreDataStack.managedObjectContext.refresh(device, mergeChanges: true)
                //birthday buddies
                //https://github.com/mrPronin/IntermediateCoreData_02_AdvancedAttributes_Challenge/blob/master/myDevices-i2-demo-starter/myDevices/DeviceDetailTableViewController.swift
            }
            
            if let deviceType = device.deviceType {
                selectedDeviceType = deviceType
                
                for (index, oneDeviceType) in deviceTypes.enumerated() {
                    if deviceType == oneDeviceType {
                        deviceTypePicker.selectRow(index, inComponent: 0, animated: false)
                        break;
                    }
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        if let device = pDevice,
            let name = nameTextField.text,
            let deviceId = deviceIdentifierTextField.text {
            device.name = name
            device.deviceType = selectedDeviceType
            device.deviceID = deviceId
            device.purchaseDate = selectedDate as Date?
            device.image = imageView?.image
        } else if pDevice == nil {
            if let name = nameTextField.text,
                let deviceType = deviceTypeTextField.text,
                let deviceId = deviceIdentifierTextField.text,
                let entity = NSEntityDescription.entity(forEntityName: "Device", in: coreDataStack.managedObjectContext),
                !name.isEmpty,
                !deviceType.isEmpty {
                pDevice = Device(entity: entity, insertInto: coreDataStack.managedObjectContext)
                pDevice?.name = name
                pDevice?.deviceType = selectedDeviceType
                pDevice?.deviceID = deviceId
                pDevice?.purchaseDate = selectedDate! as Date
                pDevice?.image = imageView?.image
            }
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        coreDataStack.saveMainContext()
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let elapsedTime = (endTime - startTime) * 1000
        print("Saving the context took \(elapsedTime) ms")

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
        if indexPath.section == 1 && indexPath.row == 0 {
            if let personPicker = storyboard?.instantiateViewController(identifier: "People") as? PeopleTableViewController {
                // more personPicker setup code here
                personPicker.pickerDelegate = self
                personPicker.selectedPerson = pDevice?.owner
                personPicker.coreDataStack = coreDataStack
                
                navigationController?.pushViewController(personPicker, animated: true)
            }
        } else if indexPath.section == 2 && indexPath.row == 0 {
            let sheet = UIAlertController(title: "Device Image", message: nil, preferredStyle: .actionSheet)
            
            sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            if imageView.image != nil {
                sheet.addAction(UIAlertAction(title: "Remove current image", style: .destructive, handler: { (action) -> Void in

                    DispatchQueue.global(qos: .background).async {
                        // Background Thread
                        DispatchQueue.main.async {
                            self.imageView.image = nil
                        }
                    }
                }))
            }
            
            sheet.addAction(UIAlertAction(title: "Select image from library", style: .default, handler: { (action) -> Void in
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)

            }))
            self.present(sheet, animated: true, completion: nil)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
    func loadDeviceTypes() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DeviceType")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
        ]
        
        do {
            if let results = try coreDataStack.managedObjectContext.fetch(fetchRequest) as? [DeviceType] {
                deviceTypes = results
            }
        } catch {
            fatalError("There was an error fetching the list of device types!")
        }
    }
    
    func datePickerValueChanged(datePicker: UIDatePicker) {
        purchaseDateTextField.text = dateFormatter.string(from: datePicker.date)
        selectedDate = dateFormatter.date(from: purchaseDateTextField.text!) as NSDate?
    }
}

extension DeviceDetailTableViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return deviceTypes[row].name
  }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    selectedDeviceType = deviceTypes[row]
    deviceTypeTextField.text = selectedDeviceType?.name
  }
}

extension DeviceDetailTableViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return deviceTypes.count
    }
}

extension DeviceDetailTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        DispatchQueue.global(qos: .background).async {
            // Background Thread
            DispatchQueue.main.async {
                if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                    self.imageView.image = image
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension DeviceDetailTableViewController: PersonPickerDelegate {
    func didSelectPerson(person: Person) {
        pDevice?.owner = person
        
        coreDataStack.saveMainContext()
    }
}
