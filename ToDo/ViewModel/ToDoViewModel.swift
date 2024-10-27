//
//  ToDoViewModel.swift
//  ToDo
//
//  Created by Mit Patel on 22/10/24.
//

import SwiftUI
import Photos
import AVFoundation

class ToDoViewModel: ObservableObject {
    
    static let shared = ToDoViewModel()
        
    @Published var todos: [ToDo] = []
    @Published var selectedTodo: ToDo?
    @Published var searchText: String = ""
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var dueTime: Date = Date()
    @Published var image: UIImage? = nil
    @Published var isCompleted: Bool = false
    @Published var showingImagePicker = false
    @Published var showPermissionAlert = false
    @Published var isCameraPicker = false
    
    @Published var alertMessage: String = ""
    @Published var successAlert: Bool = false
    @Published var showAlert: Bool = false
    @Published var showingDeleteAlert = false
    
    let todosFileURL: URL
    let todosKey = "storedTodos"
    let imageFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("ToDoImages")

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
            self.showAlert(with: "Title is required.")
            return
        }else if description.isEmpty {
            self.showAlert(with: "Description is required.")
            return
        }else{
            let imageFileName = saveImageToDisk()
            
            if let todo = updateToDo, let index = todos.firstIndex(where: { $0.id == todo.id }) {
                self.todos[index].title = self.title
                self.todos[index].description = self.description
                self.todos[index].imageFileName = imageFileName
                self.todos[index].dueTime = self.dueTime
                saveToDos()
            } else {
                let newToDo = ToDo(id: UUID(), title: self.title, description: self.description, imageFileName: imageFileName, isCompleted: false, dueTime: self.dueTime)
                todos.append(newToDo)
                saveToDos()
            }
        }
    }
    
    func toggleCompletion(for todo: ToDo) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index].isCompleted.toggle()
            saveToDos()
            loadToDos()
        }
    }
    
    private func saveImageToDisk() -> String? {
        guard let image = image else { return nil }
        let imageName = UUID().uuidString + ".jpg"
        let imagePath = imageFolder.appendingPathComponent(imageName)
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            try? imageData.write(to: imagePath)
            return imageName
        }
        return nil
    }
    
    func deleteToDo(_ todo: ToDo) {
        todos.removeAll { $0.id == todo.id }
        if let imageFileName = todo.imageFileName {
            deleteImage(with: imageFileName)
        }
        saveToDos()
        loadToDos()
    }
    
    func deleteImage(with fileName: String) {
        let imageURL = imageFolder.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: imageURL)
    }

    func saveToDos() {
        let encoder = JSONEncoder()
        do {
            let encodedData = try encoder.encode(todos)
            try encodedData.write(to: todosFileURL)
            self.successAlert = true
        } catch {
            self.showAlert(with: "Failed to save todos.")
        }
    }
    
    private func showAlert(with message: String) {
        guard !showAlert else { return } 
        alertMessage = message
        showAlert = true
    }

    func loadToDos() {
        let decoder = JSONDecoder()
        do {
            let data = try Data(contentsOf: todosFileURL)
            let decodedTodos = try decoder.decode([ToDo].self, from: data)
            self.todos = decodedTodos
        } catch {
            self.showAlert(with: "Error loading todos: \(error.localizedDescription)")
        }
    }
    
    func convertDateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy hh:mm a"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: date)
    }
    
    func convertStringToDate(dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy hh:mm a"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.date(from: dateString)
    }

    func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            showingImagePicker = true
            isCameraPicker = true
        case .denied, .restricted:
            showPermissionAlert = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.showingImagePicker = true
                        self.isCameraPicker = true
                    } else {
                        self.showPermissionAlert = true
                    }
                }
            }
        default:
            showPermissionAlert = true
        }
    }

    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            showingImagePicker = true
        case .denied, .restricted:
            showPermissionAlert = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized {
                        self.showingImagePicker = true
                    } else {
                        self.showPermissionAlert = true
                    }
                }
            }
        default:
            showPermissionAlert = true
        }
    }
}
enum PermissionType {
    case video
    case photoLibrary
}
