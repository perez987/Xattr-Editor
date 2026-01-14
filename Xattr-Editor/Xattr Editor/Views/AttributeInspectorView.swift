//
//  AttributeInspectorView.swift
//  Xattr Editor
//
//  SwiftUI view for viewing and editing file extended attributes
//

import SwiftUI

struct AttributeInspectorView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    let fileURL: URL
    let windowId: UUID

    @State private var attributes: [Attribute] = []
    @State private var selectedAttribute: Attribute?
    @State private var attributeValue: String = ""
    @State private var showingAddAlert = false
    @State private var newAttributeName = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingRemoveAlert = false
    @State private var removeMessage = ""

    var body: some View {
        HStack(spacing: 0) {
            // Left side: Attributes list
            VStack(spacing: 0) {
                // Toolbar
                HStack {
                    Button(action: refresh) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .help(NSLocalizedString("help_refresh", comment: "Refresh button help"))

                    Spacer()

                    Button {
                        showingAddAlert = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .help(NSLocalizedString("help_add_attribute", comment: "Add attribute button help"))

                    Button(action: removeAttribute) {
                        Image(systemName: "minus")
                    }
                    .disabled(selectedAttribute == nil)
                    .help(NSLocalizedString("help_remove_attribute", comment: "Remove attribute button help"))

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                    .help(NSLocalizedString("help_close", comment: "Close button help"))
                }
                .padding(6)
                .background(Color(nsColor: .controlBackgroundColor))

                Divider()

                // Attributes table
                List(selection: $selectedAttribute) {
                    ForEach(attributes) { attribute in
                        AttributeRowView(attribute: attribute)
                            .tag(attribute)
                    }
                }
                .listStyle(.inset)
            }
            .frame(width: 290, height: 380)
            .padding(.leading, 10)

            Divider()

            // Right side: Attribute value editor
            VStack(spacing: 0) {
                if selectedAttribute != nil {
                    TextEditorWithLineNumbers(text: $attributeValue)
                        .onChange(of: attributeValue) { _, newValue in
                            if let attr = selectedAttribute, newValue != attr.value {
                                attr.value = newValue
                                saveAttributes()
                            }
                        }
                } else {
                    Text(NSLocalizedString("select_attribute_message", comment: "Select attribute message"))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(width: 380, height: 389)
        }
        .frame(width: 690, height: 400)
        .navigationTitle(fileURL.lastPathComponent)
        .onAppear(perform: refresh)
        .onChange(of: selectedAttribute) { _, newValue in
            attributeValue = newValue?.value ?? ""
        }
        .alert(NSLocalizedString("add_attribute_alert_title", comment: "Add attribute alert title"), isPresented: $showingAddAlert) {
            TextField(
                NSLocalizedString("add_attribute_title", comment: "Add attribute dialog title"),
                text: $newAttributeName
            )
            Button(NSLocalizedString("cancel", comment: "Cancel button"), role: .cancel) {
                newAttributeName = ""
            }
            Button(NSLocalizedString("ok", comment: "Ok button")) {
                addAttribute()
            }
        }
        .alert(NSLocalizedString("error_title", comment: "Error title"), isPresented: $showingError) {
            Button(NSLocalizedString("ok", comment: "Ok button"), role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .alert(
            NSLocalizedString("attribute_removed_title", comment: "Attribute removed title"),
            isPresented: $showingRemoveAlert
        ) {
            Button(NSLocalizedString("ok", comment: "Ok button"), role: .cancel) {}
        } message: {
            Text(removeMessage)
        }
    }

    private func refresh() {
        do {
            guard let attrs = try fileURL.attributes() else {
                attributes = []
                return
            }

            attributes = attrs.map { Attribute(name: $0.key, value: $0.value) }
                .sorted { $0.name < $1.name }
        } catch let error as NSError {
            showError(error)
        }
    }

    private func addAttribute() {
        guard !newAttributeName.isEmpty else { return }

        do {
            try fileURL.setAttribute(name: newAttributeName, value: "")
            newAttributeName = ""
            refresh()
        } catch let error as NSError {
            showError(error)
        }
    }

    private func removeAttribute() {
        guard let attribute = selectedAttribute else { return }

        do {
            try fileURL.removeAttribute(name: attribute.name)
            removeMessage = String(
                format: NSLocalizedString("attribute_removed_message", comment: "Attribute removed message"),
                attribute.name
            )
            showingRemoveAlert = true
            selectedAttribute = nil
            attributeValue = ""
            refresh()
        } catch let error as NSError {
            showError(error)
        }
    }

    private func saveAttributes() {
        guard let attribute = selectedAttribute else { return }
        guard attribute.isModified else { return }

        do {
            try fileURL.removeAttribute(name: attribute.originalName)
            try fileURL.setAttribute(name: attribute.name, value: attribute.value ?? "")
            attribute.updateOriginalValues()
        } catch let error as NSError {
            showError(error)
        }
    }

    private func showError(_ error: NSError) {
        errorMessage = String(
            format: NSLocalizedString("error_code", comment: "Error code message"),
            error.code
        ) + "\n" + error.domain
        showingError = true
    }
}

struct AttributeRowView: View {
    @ObservedObject var attribute: Attribute

    var body: some View {
        HStack {
            TextField("", text: $attribute.name)
                .textFieldStyle(.plain)
                .onSubmit {
                    // Attribute name change will be handled by the parent view
                }

            if attribute.isModified {
                Image(systemName: "circle.fill")
                    .font(.system(size: 6))
                    .foregroundColor(.accentColor)
            }
        }
    }
}

struct TextEditorWithLineNumbers: View {
    @Binding var text: String

    var body: some View {
        TextEditor(text: $text)
//            .font(.system(size: NSFont.systemFontSize, design: .monospaced))
            .font(.system(.body))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(4)
    }
}

#Preview {
    AttributeInspectorView(fileURL: URL(fileURLWithPath: "/tmp/test"), windowId: UUID())
        .environmentObject(AppState())
}
