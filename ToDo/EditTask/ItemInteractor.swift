//
//  ItemInteractor.swift
//  ToDo
//
//  Created by Kirill Suvorov on 20.07.2025.
//

import Foundation
import CoreData

protocol ItemInteractorProtocol {
    func saveItem(item: Item?, title: String, description: String, context: NSManagedObjectContext) throws
}

class ItemInteractor: ItemInteractorProtocol {
    func saveItem(item: Item?, title: String, description: String, context: NSManagedObjectContext) throws {
        if let item = item {
            item.title = title
            item.desc = description
            item.timestamp = Date()
        } else {
            let newItem = Item(context: context)
            newItem.title = title
            newItem.desc = description
            newItem.timestamp = Date()
            newItem.state = false
        }
        try context.save()
    }
    
}
