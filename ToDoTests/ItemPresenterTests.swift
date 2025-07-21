//
//  ItemPresenterTests.swift
//  ToDoTests
//
//  Created by Kirill Suvorov on 21.07.2025.
//

import XCTest
import CoreData
@testable import ToDo

class MockItemInteractor: ItemInteractorProtocol {
    var saveItemCalled = false
    var receivedTitle: String?
    var receivedDescription: String?
    var shouldThrow = false

    func saveItem(item: Item?, title: String, description: String, context: NSManagedObjectContext) throws {
        saveItemCalled = true
        receivedTitle = title
        receivedDescription = description
        if shouldThrow {
            throw NSError(domain: "Test", code: 1, userInfo: nil)
        }
    }
}

class ItemPresenterTests: XCTestCase {
    var presenter: ItemPresenter!
    var mockInteractor: MockItemInteractor!
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        mockInteractor = MockItemInteractor()
        let container = NSPersistentContainer(name: "ToDo")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }
        context = container.viewContext
        presenter = ItemPresenter(interactor: mockInteractor, context: context)
    }

    func testSaveItemSuccess() {
        let expectation = XCTestExpectation(description: "onSaved called")
        presenter.onSaved = {
            expectation.fulfill()
        }
        presenter.saveItem(item: nil, title: "Test", description: "Desc")
        XCTAssertTrue(mockInteractor.saveItemCalled)
        XCTAssertEqual(mockInteractor.receivedTitle, "Test")
        XCTAssertEqual(mockInteractor.receivedDescription, "Desc")
        wait(for: [expectation], timeout: 1)
    }

    func testSaveItemFailure() {
        let expectation = XCTestExpectation(description: "onError called")
        mockInteractor.shouldThrow = true
        presenter.onError = { error in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        presenter.saveItem(item: nil, title: "Fail", description: "Fail")
        wait(for: [expectation], timeout: 1)
    }
}
