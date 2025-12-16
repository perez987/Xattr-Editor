//
//  AppDelegate.swift
//  Xattr Editor
//
//  Created by Richard Csiko on 2017. 01. 21..
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let openWindowController = OpenFileWindowController(
        windowNibName: "OpenFileWindow")
    var inspectorWindowControllers = [NSWindowController]()

    func openFileAttributeInspector(forFile fileURL: URL) {
        let attributeInspectorWindowController =
            AttributeInspectorWindowController(
                windowNibName: "AttributeInspectorWindow")
        inspectorWindowControllers.append(attributeInspectorWindowController)
        attributeInspectorWindowController.closeCallback = { [weak self] in
            self?.handleInspectorWindowClose(attributeInspectorWindowController)
        }
        attributeInspectorWindowController.fileURL = fileURL
        attributeInspectorWindowController.showWindow(nil)
        openWindowController.close()
    }

    func handleInspectorWindowClose(_ windowController: NSWindowController) {
        // Remove the closed window controller from the array
        inspectorWindowControllers.removeAll { $0 === windowController }

        // If no inspector windows are open, show the open file window
        if inspectorWindowControllers.isEmpty {
            openWindowController.showWindow(nil)
        }
    }

    @IBAction func showOpenDialog(_: AnyObject) {
        let fileDialog = NSOpenPanel()
        fileDialog.runModal()

        if let url = fileDialog.url {
            openFileAttributeInspector(forFile: url)
        }
    }

    func applicationDidFinishLaunching(_: Notification) {
        openWindowController.showWindow(nil)
        openWindowController.openCallback = { [weak self] url in
            self?.openFileAttributeInspector(forFile: url)
        }
    }

    func application(_: NSApplication, openFile filename: String) -> Bool {
        let url = URL(fileURLWithPath: filename)
        openFileAttributeInspector(forFile: url)
        return true
    }

    func applicationShouldHandleReopen(
        _: NSApplication, hasVisibleWindows flag: Bool
    ) -> Bool {
        if flag {
            return false
        } else {
            openWindowController.window?.makeKeyAndOrderFront(nil)
            return true
        }
    }

    func applicationSupportsSecureRestorableState(_: NSApplication) -> Bool {
        return true
    }
}
