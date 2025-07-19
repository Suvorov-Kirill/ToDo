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
    @State private var searchText = ""
    @FocusState private var isSearchFieldFocused: Bool

    private var predicate: NSPredicate? {
        searchText.isEmpty ? nil :
        NSPredicate(format: "title CONTAINS[cd] %@ OR desc CONTAINS[cd] %@", searchText, searchText)
    }

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default
    ) private var items: FetchedResults<Item>

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Заголовок
                HStack {
                    Text("Задачи")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    Spacer()
                }
                .padding(.vertical)

                // Поисковая строка
                HStack {
                    Button {
                        isSearchFieldFocused = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                    }
                    TextField("Search", text: $searchText)
                        .foregroundColor(.primary)
                        .padding(.vertical, 8)
                        .focused($isSearchFieldFocused)
                }
                .padding(.horizontal)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.bottom, 8)

                // Список задач
                List {
                    ForEach(items) { item in
                        let shareText = "\(item.title ?? "Без названия")\n\n\(item.desc ?? "")"

                        HStack(alignment: .top, spacing: 12) {
                            Button {
                                item.state.toggle()
                                do {
                                    try viewContext.save()
                                } catch {
                                    print(error.localizedDescription)
                                }
                            } label: {
                                Image(systemName: item.state ? "checkmark.circle" : "circle")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(.yellow)
                                    .padding(.top, 2)
                            }
                            .buttonStyle(.plain)

                            NavigationLink(destination: ItemView(item: item)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title ?? "Задача")
                                        .foregroundColor(.primary)
                                        .bold()
                                    Text(item.desc ?? "Описание")
                                        .foregroundColor(.secondary)
                                    if let timestamp = item.timestamp {
                                        Text(timestamp, formatter: itemFormatter)
                                            .foregroundColor(.secondary)
                                            .font(.subheadline)
                                    }
                                }
                            }
                        }
                        .listRowBackground(Color(.systemBackground))
                        .contextMenu {
                            NavigationLink(destination: ItemView(item: item)) {
                                Label("Редактировать", systemImage: "pencil")
                            }
                            ShareLink(item: shareText) {
                                Label("Поделиться", systemImage: "square.and.arrow.up")
                            }
                            Button(role: .destructive) {
                                delete(item)
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .scrollContentBackground(.hidden)
                .background(Color(.systemBackground))
                .listStyle(.plain)
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: searchText) { _,_ in
                    items.nsPredicate = predicate
                }

                // Нижняя панель
                HStack {
                    Spacer()
                    Text("\(items.count) Задач")
                        .foregroundColor(.secondary)
                    Spacer()
                    NavigationLink(destination: ItemView()) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 26))
                            .foregroundColor(.yellow)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .onAppear {
                items.nsPredicate = predicate
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            try? viewContext.save()
        }
    }

    private func delete(_ item: Item) {
        viewContext.delete(item)
        try? viewContext.save()
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
