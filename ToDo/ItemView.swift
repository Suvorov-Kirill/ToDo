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
    //@ObservedObject var item: Item
    @Environment(\.dismiss) private var dismiss
    
    var item: Item?
    @State private var title = ""
    @State private var description = ""
    
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
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if let item = item {
                title = item.title ?? ""
                description = item.desc ?? ""
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    saveItem()
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
    private func saveItem(){
        if item != nil {
            item?.title = title
            item?.desc = description
            item?.timestamp = Date()
        } else {
            let newItem = Item(context: viewContext)
            newItem.title = title
            newItem.desc = description
            newItem.timestamp = Date()
            newItem.state = false
        }
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print(error.localizedDescription)
        }
    }
}

#Preview {
    ItemView()
}
