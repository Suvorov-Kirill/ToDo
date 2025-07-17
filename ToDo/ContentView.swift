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
        NavigationStack {
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
                            
                            let shareText = "\(item.title ?? "Без названия")\n\n\(item.desc ?? "")"
                            
                            HStack(alignment: .top, spacing: 12) {
                                Button {
                                    item.state.toggle()
                                    do{
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
                            }
                            .listRowBackground(Color.black)
                            .contextMenu{
                                Button {
                                    // Добавить действие редактирования
                                } label: {
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
                    .background(Color.black)
                    .listStyle(.plain)
                    
                    HStack {
                        Spacer()
                        Text("\(items.count) Задач")
                            .foregroundColor(.gray)
                        Spacer()
                        NavigationLink(destination: ItemView()) {
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
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            try? viewContext.save()
        }
    }
    
    private func delete(_ item: Item){
        viewContext.delete(item)
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
