//
//  ContentView.swift
//  ToDo
//
//  Created by Kirill Suvorov on 16.07.2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text("Задачи")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    Spacer()
                }
                .padding(.top)

                List {
                    ForEach(items) { item in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "circle")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.yellow)
                                .padding(.top, 2)

                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(item.title ?? "Задача")
                                        .foregroundColor(.white)
                                        .bold()
                                }
                                Text(item.desc ?? "Описание")
                                    .foregroundColor(.white)
                                Text(item.timestamp!, formatter: itemFormatter)
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                                
                            }
                        }
                        .listRowBackground(Color.black)
                    }
                    .onDelete(perform: deleteItems)
                }
                .scrollContentBackground(.hidden)
                .background(Color.black)
                .listStyle(.plain)

                HStack {
                    Spacer()
                    Text("\(items.count) Задач")
                        .foregroundColor(.gray)
                    Spacer()
                    Button(action: addItem) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 26))
                            .foregroundColor(.yellow)
                    }
                }
                .padding()
                .background(Color.black)
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            try? viewContext.save()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            try? viewContext.save()
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yy"
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
