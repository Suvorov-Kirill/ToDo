//
//  TaskListRouter.swift
//  ToDo
//
//  Created by Kirill Suvorov on 20.07.2025.
//

import SwiftUI
import CoreData

final class TasksListRouter {
    static func assembleModule(context: NSManagedObjectContext) -> some View {
        let interactor = TasksListInteractor()
        let presenter = TasksListPresenter(interactor: interactor, context: context)
        return TasksListView(presenter: presenter)
    }
}
