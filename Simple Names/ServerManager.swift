//
//  ServerManager.swift
//  Simple Names
//
//  Created by Ruslan Arhypenko on 3/28/19.
//  Copyright © 2019 Ruslan Arhypenko. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class ServerManager: NSObject {
    
    static let sharedManager = ServerManager()
    
    let viewContext = CoreDataManager.sharedManager.persistentContainer.viewContext

    func getContactsFromAPI() {

        let urlString = "http://www.filltext.com/?rows=10&name=%7BfirstName%7D~%7BlastName%7D&mail=%7Bemail%7D&id=%7Bindex%7D&pretty=true"
        
        Alamofire.request(urlString).responseJSON { response in
            switch response.result {
            case .success(let value):
                                
                let JSON = value as! [NSDictionary]

                for obj in JSON {
                    let contact = NSEntityDescription.insertNewObject(forEntityName: "Contact", into: self.viewContext) as! Contact
                    contact.name = obj["name"] as? String
                    contact.email = obj["mail"] as? String
                    contact.id = obj["id"] as! Int64
                    contact.isManuallyCreated = false
                    
                    CoreDataManager.sharedManager.addContactToCoreData(contact: contact)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
