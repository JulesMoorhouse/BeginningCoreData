//
//  PeopleTableViewController.swift
//  BeginningCoreData
//
//  Created by Julian Moorhouse on 28/03/2020.
//  Copyright © 2020 Mindwarp Consultancy Ltd. All rights reserved.
//

import CoreData
import UIKit

protocol PersonPickerDelegate: class {
    func didSelectPerson(person: Person)
}

@objcMembers
class PeopleTableViewController: UITableViewController {
    var coreDataStack: CoreDataStack!
    var people = [Person]()

    // for person select mode
    weak var pickerDelegate: PersonPickerDelegate?
    var selectedPerson: Person?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "People"

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPerson(sender:)))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        reloadData()
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ruPeople", for: indexPath)

        let person = people[indexPath.row]
        cell.textLabel?.text = person.name

        if selectedPerson == person {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let person = people[indexPath.row]
        navigationController?.popViewController(animated: true)

        if let pickerDelegate = self.pickerDelegate {
            selectedPerson = person
            pickerDelegate.didSelectPerson(person: person)
            tableView.reloadData()
        } else {
            if let devicesTableViewController = storyboard?.instantiateViewController(identifier: "Devices")
                as? DevicesTableViewController {
                let person = people[indexPath.row]
                devicesTableViewController.coreDataStack = coreDataStack
                devicesTableViewController.selectedPerson = person
                navigationController?.pushViewController(devicesTableViewController, animated: true)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        // If we've set the a delgate we're assigning an owner / detail view
        return pickerDelegate == nil
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let person = people[indexPath.row]
            // Delete the row from the data source
            coreDataStack.managedObjectContext.delete(person)
            reloadData()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

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

    func reloadData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        do {
            if let results = try coreDataStack.managedObjectContext.fetch(fetchRequest) as? [Person] {
                people = results
                tableView.reloadData()
            }
        } catch {
            fatalError("There was an error fetching the list of people!")
        }
    }

    func addPerson(sender: AnyObject?) {
        // Ther overall alert controller
        let alert = UIAlertController(title: "Add a Person", message: "Name?", preferredStyle: .alert)

        // The Add button: adds a new person
        let addAction = UIAlertAction(title: "OK", style: .default) { (_) -> Void
            in
            // If the user entered a non-empty string, add a new Person
            if let textField = alert.textFields?[0],
                let personEntity = NSEntityDescription.entity(forEntityName: "Person", in: self.coreDataStack.managedObjectContext),
                let text = textField.text, !text.isEmpty {
                let newPerson = Person(entity: personEntity, insertInto: self.coreDataStack.managedObjectContext)
                newPerson.name = text

                self.coreDataStack.saveMainContext()

                self.reloadData()
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)

        alert.addTextField(configurationHandler: nil)
        alert.addAction(addAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }
}
