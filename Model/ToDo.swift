//
//  ToDo.swift
//  ToDo
//
//  Created by Mit Patel on 22/10/24.
//

import Foundation
import SwiftUI

struct ToDo: Codable, Identifiable {
    var id: UUID
    var title: String
    var description: String
    var imageFileName: String?
    var isCompleted: Bool
    var dueTime: Date
    var image: UIImage?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case imageFileName
        case isCompleted
        case dueTime
    }
}
