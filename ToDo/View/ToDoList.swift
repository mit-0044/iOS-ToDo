//
//  ToDoList.swift
//  ToDo
//
//  Created by Mit Patel on 22/10/24.
//

import SwiftUI

struct ToDoList: View {
    
    @StateObject var viewModel = ToDoViewModel()
    @State var showingAddUpdateView = false
    @State var selectedToDo: ToDo?
    @State var todoToDelete: ToDo?

    var body: some View {
        NavigationStack {
            VStack{
                List{
                    if viewModel.todos.isEmpty {
                        Text("No ToDos available")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.filteredTodos) { todo in
                            VStack(alignment: .leading) {
                                HStack {
                                    VStack(alignment: .leading){
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
                                    if todo.isCompleted {
                                        Text("Completed")
                                            .font(.caption)
                                            .padding(5)
                                            .background(Color.green)
                                            .foregroundColor(Color.black)
                                            .cornerRadius(6)
                                    } else {
                                        Text("Pending")
                                            .font(.caption)
                                            .padding(5)
                                            .background(Color.yellow)
                                            .foregroundColor(Color.black)
                                            .cornerRadius(5)
                                    }
                                    
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    todoToDelete = todo
                                    viewModel.showingDeleteAlert = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                Button {
                                    viewModel.toggleCompletion(for: todo)
                                } label: {
                                    Label(todo.isCompleted ? "Undo" : "Complete", systemImage: todo.isCompleted ? "arrow.uturn.backward" : "checkmark")
                                }
                                .tint(todo.isCompleted ? Color.yellow : Color.green)
                                NavigationLink{
                                    AddUpdateToDo(viewModel: viewModel, todo: todo)
                                } label: {
                                    Label("Update", systemImage: "pencil")
                                }
                                .tint(.blue)
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
            .toolbar{
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink{
                        AddUpdateToDo(viewModel: viewModel)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Permission Denied"),
                      message: Text("Are you sure want to delete?"),
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
}

struct ToDoList_Previews: PreviewProvider {
    static var previews: some View {
        ToDoList()
    }
}
