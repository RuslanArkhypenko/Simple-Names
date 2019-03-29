//
//  CoreDataManager.swift
//  Simple Names
//
//  Created by Ruslan Arhypenko on 3/29/19.
//  Copyright © 2019 Ruslan Arhypenko. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager: NSObject {
    
    static let sharedManager = CoreDataManager()
    
    func addContactToCoreData(contact: Contact) {
        do {
            try contact.managedObjectContext?.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func removeContactFromCoreData() {
        
        let fetchRequest = NSFetchRequest<Contact>(entityName: "Contact")
        let result = try! self.persistentContainer.viewContext.fetch(fetchRequest)
        
        for contact in result {
            if !contact.isManuallyCreated {
                self.persistentContainer.viewContext.delete(contact)
            }
        }
        self.saveContext()
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Simple_Names")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
