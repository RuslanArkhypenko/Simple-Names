//
//  ViewController.swift
//  Simple Names
//
//  Created by Ruslan Arhypenko on 3/28/19.
//  Copyright © 2019 Ruslan Arhypenko. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UITextFieldDelegate {
   
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!

    let viewContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setRefreshControl()
        ServerManager.sharedManager.getContactsFromAPI()
    }
    
    func setRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refreshAction(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    // MARK: - UITextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isEqual(self.emailAddressTextField) {
            self.nameTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    // MARK: - UITableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedContactCell", for: indexPath) as! SavedContactTableViewCell
        let contact = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withContact: contact)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
            
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func configureCell(_ cell: SavedContactTableViewCell, withContact contact: Contact) {
        cell.emailLabel.text = contact.email
        cell.nameLabel.text = contact.name
    }
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController<Contact> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Contact> = Contact.fetchRequest()
        
        fetchRequest.fetchBatchSize = 20
        
        let manuallyCreatedDescriptor = NSSortDescriptor(key: "isManuallyCreated", ascending: false)
        let nameDescriptor = NSSortDescriptor(key: "name", ascending: true)

        fetchRequest.sortDescriptors = [manuallyCreatedDescriptor, nameDescriptor]
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.viewContext, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController<Contact>? = nil
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            configureCell(tableView.cellForRow(at: indexPath!) as! SavedContactTableViewCell, withContact: anObject as! Contact)
        case .move:
            configureCell(tableView.cellForRow(at: indexPath!) as! SavedContactTableViewCell, withContact: anObject as! Contact)
            self.tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    // MARK: - Actions
    
    @IBAction func Add(_ sender: UIButton) {
        
        if self.emailAddressTextField.text!.isEmpty || self.nameTextField.text!.isEmpty {
            let alert = UIAlertController(title: "Input fields are empty!",
                                          message: "Please fil them",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let contact = NSEntityDescription.insertNewObject(forEntityName: "Contact", into: self.viewContext) as! Contact

            contact.name = self.nameTextField.text
            contact.email = self.emailAddressTextField.text
            contact.isManuallyCreated = true

           CoreDataManager.sharedManager.addContactToCoreData(contact: contact)
        }
    }
    
    @objc func refreshAction(_ sender: UIRefreshControl) {
        
        CoreDataManager.sharedManager.removeContactFromCoreData()
        ServerManager.sharedManager.getContactsFromAPI()
        sender.endRefreshing()
    }
    
    func cleanTextFields() {
        self.emailAddressTextField.text = ""
        self.nameTextField.text = ""
    }
}

