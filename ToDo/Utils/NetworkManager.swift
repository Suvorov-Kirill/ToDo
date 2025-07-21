//
//  NetworkManager.swift
//  ToDo
//
//  Created by Kirill Suvorov on 19.07.2025.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    func fetchRequest() async throws -> [ToDoTask] {
        guard let url = URL(string: "https://dummyjson.com/todos") else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        let tasks = try JSONDecoder().decode(Todos.self, from: data)
        return tasks.todos
    }
}
