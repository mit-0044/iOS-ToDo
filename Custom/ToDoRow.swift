//
//  ToDoRow.swift
//  ToDo
//
//  Created by Mit Patel on 22/10/24.
//

import SwiftUI

struct ToDoRow: View {
    let todo: ToDo
    var onEdit: () -> Void
    var onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(todo.title)
                    .font(.headline)
                Text(todo.description)
                    .font(.subheadline)
            }
            Spacer()
            if todo.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.red)
            }
        }
        .swipeActions {
            Button {
                onEdit()
            } label: {
                Label("Edit", systemImage: "pencil")
                    .foregroundColor(.blue)
            }
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
                    .foregroundColor(.red)
            }
        }
    }
}

//struct ToDoRow_Previews: PreviewProvider {
//    @State static var id = UUID()
//    @State static var title = String()
//    @State static var description = String()
//    @State static var createdTime = Date()
//    @State static var dueTime = Date()
//    @State static var isCompleted = false
//    @State static var imageFileName: String = ""
//    @State static var todo = ToDo(id: UUID(), title: title, description: description, imageFileName: imageFileName, isCompleted: isCompleted, dueTime: dueTime, createdTime: createdTime)
//    static var previews: some View {
//        ToDoRow(todo: todo)
//    }
//}
