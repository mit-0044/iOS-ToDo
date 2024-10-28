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
    var isCompleted: Bool
    var dueTime: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case isCompleted
        case dueTime
    }
}
