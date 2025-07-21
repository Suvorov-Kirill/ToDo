//
//  ItemInteractorTests.swift
//  ToDoTests
//
//  Created by Kirill Suvorov on 21.07.2025.
//

import XCTest
import CoreData
@testable import ToDo

class ItemInteractorTests: XCTestCase {
    var interactor: ItemInteractor!
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        interactor = ItemInteractor()
        let container = NSPersistentContainer(name: "ToDo")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }
        context = container.viewContext
    }

    func testSaveNewItem() throws {
        try interactor.saveItem(item: nil, title: "Test", description: "Desc", context: context)
        let request = Item.fetchRequest()
        let items = try context.fetch(request)
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.title, "Test")
        XCTAssertEqual(items.first?.desc, "Desc")
    }

    func testUpdateExistingItem() throws {
        try interactor.saveItem(item: nil, title: "A", description: "B", context: context)
        let request = Item.fetchRequest()
        let item = try context.fetch(request).first
        try interactor.saveItem(item: item, title: "C", description: "D", context: context)
        XCTAssertEqual(item?.title, "C")
        XCTAssertEqual(item?.desc, "D")
    }
}
