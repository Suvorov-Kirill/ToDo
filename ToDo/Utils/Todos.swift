//
//  Todos.swift
//  ToDo
//
//  Created by Kirill Suvorov on 19.07.2025.
//

import Foundation

struct Todos: Codable, Hashable {
    let todos: [ToDoTask]
}

struct ToDoTask: Codable, Hashable {
    let todo: String
    let completed: Bool
}
