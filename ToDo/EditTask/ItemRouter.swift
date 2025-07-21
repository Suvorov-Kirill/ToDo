//
//  ItemRouter.swift
//  ToDo
//
//  Created by Kirill Suvorov on 20.07.2025.
//

import SwiftUI
import CoreData

final class ItemRouter {
    static func assemblemodule(item: Item?, context: NSManagedObjectContext) -> some View {
        let interactor = ItemInteractor()
        let presenter = ItemPresenter(interactor: interactor, context: context)
        return ItemView(item: item, presenter: presenter)
    }
}
