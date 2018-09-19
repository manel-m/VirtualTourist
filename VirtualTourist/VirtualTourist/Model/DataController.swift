//
//  DataController.swift
//  VirtualTourist
//
//  Created by Manel matougui on 9/17/18.
//  Copyright © 2018 udacity. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    let persistentContainer : NSPersistentContainer
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init (modelName: String){
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    func load (completion: (() -> Void)? = nil){
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
}
