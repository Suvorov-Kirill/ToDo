//
//  ToDoApp.swift
//  ToDo
//
//  Created by Kirill Suvorov on 16.07.2025.
//

import SwiftUI

@main
struct ToDoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            TasksListRouter.assembleModule(context: persistenceController.container.viewContext)
        }
    }
}
