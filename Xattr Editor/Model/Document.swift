//
//  Document.swift
//  Xattr Editor
//

import AppKit

// Minimal NSDocument subclass overriding autosavesInPlace
// to fix autosavesInPlace warnings in console
class Document: NSDocument {
    override class var autosavesInPlace: Bool {
        return true
    }
}
