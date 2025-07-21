//
//  TaskListPresenter.swift
//  ToDo
//
//  Created by Kirill Suvorov on 20.07.2025.
//

import Foundation
import CoreData

class TasksListPresenter: ObservableObject {
    @Published var items: [Item] = []
    let interactor: TasksListInteractor
    let context: NSManagedObjectContext
    @Published var searchText: String = ""
    @Published var isListening: Bool = false
    
    init(interactor: TasksListInteractor, context: NSManagedObjectContext) {
        self.interactor = interactor
        self.context = context
        fetchItems()
        NotificationCenter.default.addObserver(self, selector: #selector(itemsUpdated), name: .didUpdateItems, object: nil)
    }
    
    @objc private func itemsUpdated() {
        fetchItems()
    }
    
    func fetchItems() {
        let items = interactor.fetchItems(context: context)
        DispatchQueue.main.async {
            self.items = items
        }
    }
    
    func search(text: String) {
        searchText = text
        items = interactor.searchItems(text: text, context: context)
    }
    
    func toggleState(for item: Item) {
        interactor.toggleState(for: item, context: context)
        if searchText.isEmpty{
            fetchItems()
        } else {
            search(text: searchText)
        }
    }
    
    func delete(item: Item) {
        interactor.delete(item: item, context: context)
        fetchItems()
    }
    
    func deleteItems(at offsets: IndexSet) {
        interactor.deleteItems(at: offsets, items: items, context: context)
        fetchItems()
    }
    
    func initialFetch() async {
        if interactor.isFirstLaunch() {
            await loadNetworkTodos()
            interactor.setDidLoadTasksFlag()
            fetchItems()
        } else {
            fetchItems()
        }
    }
    
    func loadNetworkTodos() async {
        do {
            let todos = try await interactor.loadNetworkTodos()
            await MainActor.run {
                for item in todos {
                    let newItem = Item(context: context)
                    newItem.title = item.todo
                    newItem.state = item.completed
                    newItem.timestamp = Date()
                }
                try? context.save()
                fetchItems()
            }
        } catch {
            print(error.localizedDescription)
        }
    
    }
    
    func startVoiceSearch() {
        interactor.startSpeechRecognition(
            onResult: { [weak self] text in
                DispatchQueue.main.async {
                    self?.searchText = text
                    self?.items = self?.interactor.searchItems(text: text, context: self?.context ?? NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)) ?? []
                }
            },
            onStateChange: { [weak self] listening in
                DispatchQueue.main.async {
                    self?.isListening = listening
                }
            }
        )
    }
    
    func stopVoiceSearch() {
        interactor.stopSpeechRecognition()
        isListening = false
    }
    
}
