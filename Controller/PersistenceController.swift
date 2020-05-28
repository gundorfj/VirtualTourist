//
//  PersistenceController.swift
//  VirtualTourist
//
//  Created by Jan Gundorf on 28/05/2020.
//  Copyright © 2020 Jan Gundorf. All rights reserved.
//

import Foundation
import CoreData

class PersistenceController {
    let persistentContainer: NSPersistentContainer
        
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func load(completion: (()->Void)? = nil){
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
}
