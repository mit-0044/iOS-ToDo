//
//  ToDoViewModel.swift
//  ToDo
//
//  Created by Mit Patel on 22/10/24.
//

import SwiftUI

class ToDoViewModel: ObservableObject {
    
    static let shared = ToDoViewModel()
        
    @Published var todos: [ToDo] = []
    @Published var searchText: String = ""
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var dueTime: Date = Date()
    
    @Published var isLoading: Bool = false
    @Published var alertMessage: String = ""
    @Published var successAlert: Bool = false
    @Published var showAlert: Bool = false
    @Published var showingDeleteAlert = false
    
    let todosFileURL: URL

    init() {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.todosFileURL = documentsDirectory.appendingPathComponent("todos.json")
        loadToDos()
    }
    
    var filteredTodos: [ToDo] {
        if searchText.isEmpty {
            return todos
        } else {
            return todos.filter { todo in
                todo.title.lowercased().contains(searchText.lowercased()) ||
                todo.description.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    func validateAndSave(updateToDo: ToDo? = nil) {
        if title.isEmpty {
            showAlert(with: "Title is required.")
            return
        }
        
        if description.isEmpty {
            showAlert(with: "Description is required.")
            return
        }
        
        if let todo = updateToDo, let index = todos.firstIndex(where: { $0.id == todo.id }) {
            self.todos[index].title = self.title
            self.todos[index].description = self.description
            self.todos[index].dueTime = self.dueTime
            saveToDos()
            successAlert = true
        } else {
            let newToDo = ToDo(id: UUID(), title: self.title, description: self.description, isCompleted: false, dueTime: self.dueTime)
            todos.append(newToDo)
            saveToDos()
            successAlert = true
        }
    }
    
    func toggleCompletion(for todo: ToDo) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index].isCompleted.toggle()
            saveToDos()
        }
    }
    
    func deleteToDo(_ todo: ToDo) {
        todos.removeAll { $0.id == todo.id }
        saveToDos()
        showingDeleteAlert = true
    }

    func saveToDos() {
        let encoder = JSONEncoder()
        do {
            let encodedData = try encoder.encode(todos)
            try encodedData.write(to: todosFileURL)
        } catch {
            showAlert(with: "Failed to save todos.")
        }
    }
    
    private func showAlert(with message: String) {
        showAlert = true
        alertMessage = message
    }

    func loadToDos() {
        let decoder = JSONDecoder()
        do {
            let data = try Data(contentsOf: todosFileURL)
            let decodedTodos = try decoder.decode([ToDo].self, from: data)
            self.todos = decodedTodos
        } catch {
            showAlert(with: "Error loading todos: \(error.localizedDescription)")
        }
    }
}
