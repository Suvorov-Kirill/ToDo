//
//  TasksListPresenterTests.swift
//  ToDoTests
//
//  Created by Kirill Suvorov on 21.07.2025.
//

import XCTest
import CoreData
@testable import ToDo

class MockTasksListInteractor: TasksListInteractor {
    var fetchItemsCalled = false
    var searchItemsCalled = false
    var toggleStateCalled = false
    var deleteItemCalled = false
    var deleteItemsCalled = false
    var lastSearchText: String?

    override func fetchItems(context: NSManagedObjectContext) -> [Item] {
        fetchItemsCalled = true
        return []
    }

    override func searchItems(text: String, context: NSManagedObjectContext) -> [Item] {
        searchItemsCalled = true
        lastSearchText = text
        return []
    }

    override func toggleState(for item: Item, context: NSManagedObjectContext) {
        toggleStateCalled = true
    }

    override func delete(item: Item, context: NSManagedObjectContext) {
        deleteItemCalled = true
    }

    override func deleteItems(at offsets: IndexSet, items: [Item], context: NSManagedObjectContext) {
        deleteItemsCalled = true
    }
}

class TasksListPresenterTests: XCTestCase {
    var presenter: TasksListPresenter!
    var mockInteractor: MockTasksListInteractor!
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        mockInteractor = MockTasksListInteractor()
        let container = NSPersistentContainer(name: "ToDo")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }
        context = container.viewContext
        presenter = TasksListPresenter(interactor: mockInteractor, context: context)
    }

    func testFetchItemsCallsInteractor() {
        presenter.fetchItems()
        XCTAssertTrue(mockInteractor.fetchItemsCalled)
    }

    func testSearchCallsInteractor() {
        presenter.search(text: "milk")
        XCTAssertTrue(mockInteractor.searchItemsCalled)
        XCTAssertEqual(mockInteractor.lastSearchText, "milk")
        XCTAssertEqual(presenter.searchText, "milk")
    }

    func testToggleStateCallsInteractor() {
        let item = Item(context: context)
        presenter.toggleState(for: item)
        XCTAssertTrue(mockInteractor.toggleStateCalled)
    }

    func testDeleteItemCallsInteractor() {
        let item = Item(context: context)
        presenter.delete(item: item)
        XCTAssertTrue(mockInteractor.deleteItemCalled)
    }

    func testDeleteItemsCallsInteractor() {
        presenter.deleteItems(at: IndexSet(integer: 0))
        XCTAssertTrue(mockInteractor.deleteItemsCalled)
    }
}
