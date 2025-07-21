//
//  ItemView.swift
//  ToDo
//
//  Created by Kirill Suvorov on 17.07.2025.
//

import SwiftUI
import CoreData

struct ItemView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    var item: Item?
    @State private var title = ""
    @State private var description = ""
    var presenter: ItemPresenter?
    
    @State private var errorMessage: String?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading){
                TextField("Задача", text: $title)
                    .font(.title)
                    .padding()
                Text(item?.timestamp ?? Date(), formatter: itemFormatter)
                    .foregroundColor(.gray)
                    .font(.subheadline)
                    .padding(.horizontal)
                TextEditor(text: $description)
                    .padding(.horizontal)
                    .padding(.top)
                    .frame(minHeight: 200)
                    .scrollDisabled(true)
                Spacer()
                if let error = errorMessage {
                    Text(error).foregroundStyle(.red).padding()
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if let item = item {
                title = item.title ?? ""
                description = item.desc ?? ""
            }
            presenter?.onSaved = { dismiss() }
            presenter?.onError = { errorMessage = $0 }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    presenter?.saveItem(item: item, title: title, description: description)
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Назад")
                    }
                    .foregroundStyle(.yellow)
                }
            }
        }

    }
}
