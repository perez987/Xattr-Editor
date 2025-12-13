//
//  AttributeInspectorWindowController.swift
//  Xattr Editor
//
//  Created by Richard Csiko on 2017. 01. 21..
//

import Cocoa

class AttributeInspectorWindowController: NSWindowController {
    // MARK: Properties

    @IBOutlet var tableView: NSTableView?
    @IBOutlet var attributeValueField: NSTextView!
    @IBOutlet var refreshButton: NSButton!
    @IBOutlet var addButton: NSButton!
    @IBOutlet var removeButton: NSButton!

    fileprivate var fileAttributes: Array? = [Attribute]()

    fileprivate var selectedAttribute: Attribute? {
        didSet {
            updateAttributeValueField(withAttribute: selectedAttribute)
        }
    }

    var fileURL: URL? {
        didSet {
            window?.title = fileURL?.lastPathComponent ?? "-"
            refresh(nil)
        }
    }

    // MARK: Overrides

    override func windowDidLoad() {
        super.windowDidLoad()
        tableView?.reloadData()

        refreshButton.image = NSImage(named: NSImage.refreshTemplateName)
        addButton.image = NSImage(named: NSImage.addTemplateName)
        removeButton.image = NSImage(named: NSImage.removeTemplateName)

        attributeValueField.isAutomaticQuoteSubstitutionEnabled = false

        attributeValueField.showLineNumberView()
    }

    // MARK: Utils

    func readExtendedAttributes(fromURL url: URL?) throws -> [Attribute]? {
        guard let attrs = try url?.attributes() else { return nil }
        var xAttrs = [Attribute]()

        for (key, value) in attrs {
            xAttrs.append(Attribute(name: key, value: value))
        }

        return xAttrs
    }

    func updateAttributeValueField(withAttribute attribute: Attribute?) {
        attributeValueField.string = attribute?.value ?? ""
    }

    func showErrorModal(_ error: NSError) {
        let alert = NSAlert()
        alert.messageText = String(format: NSLocalizedString("error_code", comment: "Error code message"), error.code)
        alert.informativeText = error.domain
        alert.alertStyle = .critical
        alert.runModal()
    }

    // MARK: Actions

    @IBAction func saveExtendedAttributes(_: AnyObject?) {
        guard let attributes = fileAttributes else { return }
        guard let url = fileURL else { return }

        for attribute in attributes where attribute.isModified {
            do {
                try url.removeAttribute(name: attribute.originalName)
                try url.setAttribute(name: attribute.name, value: attribute.value ?? "")
                // Update original values after successful save to prevent re-attempting the same operation
                attribute.updateOriginalValues()
            } catch let error as NSError {
                showErrorModal(error)
            }
        }
    }

    @IBAction func refresh(_: AnyObject?) {
        do {
            try fileAttributes = readExtendedAttributes(fromURL: fileURL)
            tableView?.reloadData()
        } catch let error as NSError {
            showErrorModal(error)
        }
    }

    @IBAction func addAttribute(_: AnyObject?) {
        guard let url = fileURL else { return }

        let alert = NSAlert()
        alert.messageText = NSLocalizedString("add_attribute_title", comment: "Add attribute dialog title")
        alert.addButton(withTitle: NSLocalizedString("ok", comment: "Ok button"))
        alert.addButton(withTitle: NSLocalizedString("cancel", comment: "Cancel button"))

        let inputField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        inputField.bezelStyle = .roundedBezel
        alert.accessoryView = inputField

        alert.beginSheetModal(for: window!) { [weak self] response in
            if response == .alertSecondButtonReturn || inputField.stringValue.isEmpty {
                return
            }

            do {
                try url.setAttribute(name: inputField.stringValue, value: "")
                self?.refresh(nil)
            } catch let error as NSError {
                self?.showErrorModal(error)
            }
        }
    }

    @IBAction func removeAttribute(_: AnyObject?) {
        guard let attribute = selectedAttribute else { return }
        guard let url = fileURL else { return }

        do {
            let attributeName = attribute.name
            try url.removeAttribute(name: attributeName)
            refresh(nil)

            // Show success feedback
            let alert = NSAlert()
            alert.messageText = NSLocalizedString("attribute_removed_title", comment: "Attribute removed title")
            alert.informativeText = String(
                format: NSLocalizedString("attribute_removed_message", comment: "Attribute removed message"),
                attributeName
            )
            alert.alertStyle = .informational
            alert.runModal()
        } catch let error as NSError {
            showErrorModal(error)
        }
    }
}

extension AttributeInspectorWindowController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor _: NSTableColumn?, row: Int) -> NSView? {
        guard let attr = fileAttributes?[row] else {
            return nil
        }

        let identifier = NSUserInterfaceItemIdentifier(rawValue: "AttributeCellIdentifier")

        if let cell = tableView.makeView(withIdentifier: identifier, owner: nil) as? AttributeCellView {
            cell.attribute = attr
            cell.attributeDidChangeCallback = { [weak self] in
                self?.saveExtendedAttributes(nil)
            }
            return cell
        }

        return nil
    }

    func tableViewSelectionDidChange(_: Notification) {
        guard let tblView = tableView else { return }

        if tblView.selectedRow == -1 {
            selectedAttribute = nil
            return
        }

        selectedAttribute = fileAttributes?[tblView.selectedRow]
    }
}

extension AttributeInspectorWindowController: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        return fileAttributes?.count ?? 0
    }
}

extension AttributeInspectorWindowController: NSTextDelegate {
    func textDidChange(_ notification: Notification) {
        guard let editor = notification.object as? NSTextView else { return }
        guard let attribute = selectedAttribute else { return }
        if editor.string == attribute.value { return }

        selectedAttribute!.value = editor.string
    }

    func textDidEndEditing(_: Notification) {
        saveExtendedAttributes(nil)
    }
}
