//
//  AddUpdateToDo.swift
//  ToDo
//
//  Created by Mit Patel on 22/10/24.
//

import SwiftUI

struct AddUpdateToDo: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = ToDoViewModel.shared
    @State private var snapshotImage: UIImage?
    var todo: ToDo?

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false){
                VStack(alignment: .leading, spacing: 15){
                    if viewModel.showAlert {
                        Text(viewModel.alertMessage)
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                    VStack(alignment: .leading, spacing: 3){
                        Text("Title")
                        TextField("Title", text: $viewModel.title)
                            .autocorrectionDisabled(true)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    VStack(alignment: .leading, spacing: 3){
                        Text("Description")
                        TextField("Description", text: $viewModel.description)
                            .autocorrectionDisabled(true)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    DatePicker("Due Date", selection: $viewModel.dueTime, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(CompactDatePickerStyle())
                    HStack(){
                        Text("Image(Optional)")
                        Spacer()
                        Menu {
                            Button {
                                viewModel.showingImagePicker = false
                                viewModel.checkCameraPermission()
                            } label: {
                                Label("Take Photo", systemImage: "camera")
                            }

                            Button {
                                viewModel.isCameraPicker = false
                                viewModel.checkPhotoLibraryPermission()
                            } label: {
                                Label("Select Image", systemImage: "photo")
                            }
                        } label: {
                            Label("Choose Image", systemImage: "photo")
                                .foregroundColor(.blue)
                        }
                    }
                    VStack(alignment: .leading){
                        if let img = viewModel.image {
                            Text("Image:")
                                .foregroundColor(.gray)
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(10)
                        } else {
                            Text("No Image Selected")
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.9, alignment: .leading)
                    Spacer()
                }
            }
            .padding(.top)
            .frame(width: UIScreen.main.bounds.width * 0.9)
            .navigationTitle(todo == nil ? "Add To-Do" : "Update To-Do")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if todo == nil {
                        Button("Save") {
                            viewModel.validateAndSave()
                        }
                    } else {
                        Button("Update") {
                            viewModel.validateAndSave(updateToDo: todo)
                        }
                    }
                }
            }
            .onAppear {
                if let todo = todo {
                    viewModel.alertMessage = ""
                    viewModel.showAlert = false
                    viewModel.title = todo.title
                    viewModel.description = todo.description
                    viewModel.dueTime = todo.dueTime
                    viewModel.image = todo.image
                    loadImageIfExists()
                }else{
                    self.resetFields()
                }
            }
            .sheet(isPresented: $viewModel.showingImagePicker) {
                ImagePicker(image: $viewModel.image, isCamera: viewModel.isCameraPicker)
            }
            .alert(isPresented: $viewModel.showPermissionAlert) {
               Alert(title: Text("Permission Denied"),
                     message: Text("Please enable camera or photo library access in Settings."),
                     dismissButton: .default(Text("OK")))
            }
            .alert(Text("ToDO"), isPresented: $viewModel.successAlert, actions: {
                Button("Okay", role: .cancel) {
                    resetFields()
                    dismiss()
                }
            }, message: { Text( "To-Do saved successfully." ) })
        }
    }
    
    private func loadImageIfExists() {
        if let todo = todo, let imageFileName = todo.imageFileName {
            let imageURL = viewModel.imageFolder.appendingPathComponent(imageFileName)
            if let imageData = try? Data(contentsOf: imageURL),
               let loadedImage = UIImage(data: imageData) {
                viewModel.image = loadedImage
            }
        }
    }
    
    func resetFields() {
        viewModel.alertMessage = ""
        viewModel.showAlert = false
        viewModel.title = ""
        viewModel.description = ""
        viewModel.image = nil
        viewModel.dueTime = Date()
    }
    
    private func takeSnapshot() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            guard let window = scene.windows.first(where: { $0.isKeyWindow }) else { return }
            let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
            snapshotImage = renderer.image { context in
                window.layer.render(in: context.cgContext)
            }
        }
    }
}


struct AddUpdateToDo_Previews: PreviewProvider {
    static var previews: some View {
        AddUpdateToDo()
    }
}
