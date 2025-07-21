//
//  TasksListView.swift
//  ToDo
//
//  Created by Kirill Suvorov on 16.07.2025.
//

import SwiftUI
import CoreData

struct TasksListView: View {
    @ObservedObject var presenter: TasksListPresenter
    
    @FocusState private var isSearchFieldFocused: Bool
    
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
                    TextField("Search", text: $presenter.searchText)
                        .foregroundColor(.primary)
                        .padding(.vertical, 8)
                        .focused($isSearchFieldFocused)
                        .onChange(of: presenter.searchText) { _,_ in
                            presenter.search(text: presenter.searchText)
                        }
                    if !presenter.searchText.isEmpty {
                        Button {
                            presenter.searchText = ""
                            presenter.stopVoiceSearch()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                        }
                        .foregroundColor(.gray)
                    }
                    Button(action: {
                        if presenter.isListening {
                            presenter.stopVoiceSearch()
                        } else {
                            presenter.startVoiceSearch()
                        }
                    }) {
                        Image(systemName: presenter.isListening ? "mic.circle.fill" : "mic.fill")
                            .foregroundColor(presenter.isListening ? .red : .gray)
                            .scaleEffect(presenter.isListening ? 1.2 : 1.0)
                            .animation(.easeInOut, value: presenter.isListening)
                    }
                    .padding(.leading, 4)
                }
                .padding(.horizontal)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                // Список задач
                List {
                    ForEach(presenter.items) { item in
                        let shareText = "\(item.title ?? "Без названия")\n\n\(item.desc ?? "")"
                        HStack(alignment: .top, spacing: 12) {
                            Button {
                                presenter.toggleState(for: item)
                            } label: {
                                Image(systemName: item.state ? "checkmark.circle" : "circle")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(.yellow)
                                    .padding(.top, 2)
                            }
                            .buttonStyle(.plain)
                            
                            NavigationLink(destination: ItemRouter.assemblemodule(item: item, context: presenter.context)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title ?? "Задача")
                                        .foregroundColor(.primary)
                                        .bold()
                                    Text(item.desc ?? "")
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
                            NavigationLink(destination: ItemRouter.assemblemodule(item: item, context: presenter.context)) {
                                Label("Редактировать", systemImage: "pencil")
                            }
                            ShareLink(item: shareText) {
                                Label("Поделиться", systemImage: "square.and.arrow.up")
                            }
                            Button(role: .destructive) {
                                presenter.delete(item: item)
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                        }
                    }
                    .onDelete(perform: presenter.deleteItems)
                }
                .scrollContentBackground(.hidden)
                .background(Color(.systemBackground))
                .listStyle(.plain)
                .scrollDismissesKeyboard(.interactively)
                
                // Нижняя панель
                HStack {
                    Spacer()
                    Text("\(presenter.items.count) Задач")
                        .foregroundColor(.secondary)
                    Spacer()
                    NavigationLink(destination: ItemRouter.assemblemodule(item: nil, context: presenter.context)) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 26))
                            .foregroundColor(.yellow)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .onAppear {
                Task { await presenter.initialFetch() }
            }
        }
    }
}
