//
//  ItemPresenter.swift
//  ToDo
//
//  Created by Kirill Suvorov on 20.07.2025.
//

import Foundation
import CoreData

protocol ItemPresenterProtocol {
    func saveItem(item: Item?, title: String, description: String)
}

class ItemPresenter: ItemPresenterProtocol {
    var interactor: ItemInteractorProtocol
    var context: NSManagedObjectContext
    
    var onSaved: (() -> Void)?
    var onError: ((String) -> Void)?
    
    init(interactor: ItemInteractorProtocol, context: NSManagedObjectContext) {
        self.interactor = interactor
        self.context = context
    }
    
    func saveItem(item: Item?, title: String, description: String) {
        do {
            try interactor.saveItem(item: item, title: title, description: description, context: context)
            NotificationCenter.default.post(name: .didUpdateItems, object: nil)
            onSaved?()
        } catch {
            onError?(error.localizedDescription)
        }
    }
    
    
}
