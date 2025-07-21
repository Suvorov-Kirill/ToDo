//
//  Utils.swift
//  ToDo
//
//  Created by Kirill Suvorov on 17.07.2025.
//

import Foundation

let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yy"
    return formatter
}()

extension Notification.Name {
    static let didUpdateItems = Notification.Name("didUpdateItems")
}
