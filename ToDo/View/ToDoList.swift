//
//  ToDoList.swift
//  ToDo
//
//  Created by Mit Patel on 22/10/24.
//

import SwiftUI

struct ToDoList: View {
    
    @StateObject var viewModel = ToDoViewModel()
    @State private var showingAddUpdateView = false
    @State private var todoToDelete: ToDo?

    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    if viewModel.todos.isEmpty {
                        Text("No ToDos available")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.filteredTodos) { todo in
                            ToDoRow(todo: todo)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    deleteButton(for: todo)
                                    completionButton(for: todo)
                                    updateButton(for: todo)
                                }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .searchable(
                    text: $viewModel.searchText,
                    placement: .navigationBarDrawer(displayMode: .automatic),
                    prompt: "Search"
                )
            }
            .onAppear {
                viewModel.loadToDos()
            }
            .navigationTitle("ToDo List")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        AddUpdateToDo(viewModel: viewModel)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Alert"),
                      message: Text(viewModel.alertMessage),
                      dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $viewModel.showingDeleteAlert) {
                Alert(
                    title: Text("Delete To-Do"),
                    message: Text("Are you sure you want to delete this to-do?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let todo = todoToDelete {
                            viewModel.deleteToDo(todo)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    @ViewBuilder
    private func ToDoRow(todo: ToDo) -> some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(todo.title)
                        .font(.headline)
                    
                    Text(todo.description)
                        .font(.subheadline)
                        .lineLimit(2)
                    
                    Text("Due on: \(viewModel.convertDateToString(date: todo.dueTime))")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                Spacer()
                StatusView(isCompleted: todo.isCompleted)
            }
        }
    }

    @ViewBuilder
    private func StatusView(isCompleted: Bool) -> some View {
        Text(isCompleted ? "Completed" : "Pending")
            .font(.caption)
            .padding(5)
            .background(isCompleted ? Color.green : Color.yellow)
            .foregroundColor(.black)
            .cornerRadius(6)
    }

    private func deleteButton(for todo: ToDo) -> some View {
        Button(role: .destructive) {
            todoToDelete = todo
            viewModel.showingDeleteAlert = true
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }

    private func completionButton(for todo: ToDo) -> some View {
        Button {
            viewModel.toggleCompletion(for: todo)
        } label: {
            Label(todo.isCompleted ? "Undo" : "Complete", systemImage: todo.isCompleted ? "arrow.uturn.backward" : "checkmark")
        }
        .tint(todo.isCompleted ? Color.yellow : Color.green)
    }

    private func updateButton(for todo: ToDo) -> some View {
        NavigationLink {
            AddUpdateToDo(viewModel: viewModel, todo: todo)
        } label: {
            Label("Update", systemImage: "pencil")
        }
        .tint(.blue)
    }
}


struct ToDoList_Previews: PreviewProvider {
    static var previews: some View {
        ToDoList()
    }
}
