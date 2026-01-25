//
//  Attribute.swift
//  Xattr Editor
//
//  Created by Richard Csiko on 2017. 01. 21..
//

import Combine
import Foundation

class Attribute: ObservableObject, Identifiable {
    let id = UUID()
    var originalName: String
    var originalValue: String?

    @Published var name: String
    @Published var value: String?
    var isModified: Bool {
        name != originalName || value != originalValue
    }

    init(name: String, value: String? = nil) {
        originalName = name
        self.name = name

        originalValue = value
        self.value = value
    }

    func updateOriginalValues() {
        originalName = name
        originalValue = value
    }
}

extension Attribute: Hashable {
    static func == (lhs: Attribute, rhs: Attribute) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
