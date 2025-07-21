//
//  TaskListInteractor.swift
//  ToDo
//
//  Created by Kirill Suvorov on 20.07.2025.
//

import Foundation
import CoreData

class TasksListInteractor {
    func fetchItems(context: NSManagedObjectContext) -> [Item] {
        let request = Item.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)]
        let result = try? context.fetch(request)
        return result ?? []
    }

    func searchItems(text: String, context: NSManagedObjectContext) -> [Item] {
        let request = Item.fetchRequest()
        if !text.isEmpty {
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR desc CONTAINS[cd] %@", text, text)
        }
        let result = try? context.fetch(request)
        return result ?? []
    }

    func toggleState(for item: Item, context: NSManagedObjectContext) {
        item.state.toggle()
        try? context.save()
    }

    func delete(item: Item, context: NSManagedObjectContext) {
        context.delete(item)
        try? context.save()
    }

    func deleteItems(at offsets: IndexSet, items: [Item], context: NSManagedObjectContext) {
        offsets.map { items[$0] }.forEach(context.delete)
        try? context.save()
    }

    func loadNetworkTodos() async throws -> [ToDoTask] {
        try await NetworkManager.shared.fetchRequest()
    }
}
