//
//  TasksListInteractorTests.swift
//  ToDoTests
//
//  Created by Kirill Suvorov on 21.07.2025.
//

import XCTest
import CoreData
@testable import ToDo

class TasksListInteractorTests: XCTestCase {
    var interactor: TasksListInteractor!
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        interactor = TasksListInteractor()
        let container = NSPersistentContainer(name: "ToDo")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }
        context = container.viewContext
    }

    func testFetchItems() throws {
        let item = Item(context: context)
        item.title = "Test"
        item.desc = "Desc"
        item.timestamp = Date()
        try context.save()
        let items = interactor.fetchItems(context: context)
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.title, "Test")
    }

    func testSearchItems() throws {
        let item1 = Item(context: context)
        item1.title = "Milk"
        item1.desc = "Buy"
        item1.timestamp = Date()
        let item2 = Item(context: context)
        item2.title = "Read"
        item2.desc = "Book"
        item2.timestamp = Date()
        try context.save()
        let found = interactor.searchItems(text: "milk", context: context)
        XCTAssertEqual(found.count, 1)
        XCTAssertEqual(found.first?.title, "Milk")
    }

    func testToggleState() throws {
        let item = Item(context: context)
        item.title = "Test"
        item.desc = "Desc"
        item.timestamp = Date()
        item.state = false
        try context.save()
        interactor.toggleState(for: item, context: context)
        XCTAssertTrue(item.state)
    }

    func testDeleteItem() throws {
        let item = Item(context: context)
        item.title = "Test"
        try context.save()
        interactor.delete(item: item, context: context)
        let request = Item.fetchRequest()
        let items = try context.fetch(request)
        XCTAssertEqual(items.count, 0)
    }

    func testDeleteItems() throws {
        let item1 = Item(context: context)
        item1.title = "A"
        let item2 = Item(context: context)
        item2.title = "B"
        try context.save()
        let items = [item1, item2]
        interactor.deleteItems(at: IndexSet(integer: 0), items: items, context: context)
        let result = interactor.fetchItems(context: context)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.title, "B")
    }
}
