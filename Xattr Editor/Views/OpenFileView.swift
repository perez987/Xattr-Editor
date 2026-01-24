//
//  OpenFileView.swift
//  Xattr Editor
//
//  SwiftUI view for file selection
//

import SwiftUI
import UniformTypeIdentifiers

struct OpenFileView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.openWindow) private var openWindow
    @State private var isDragging = false

    var body: some View {
        VStack {
            Spacer()

            ZStack {
                // Liquid Glass background layer
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.clear)
                    .adaptiveMaterialBackground(type: .window)

                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        isDragging ? Color.accentColor : Color.gray,
                        style: StrokeStyle(lineWidth: isDragging ? 4 : 2, dash: [10])
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isDragging ? Color.accentColor.opacity(0.1) : Color.clear)
                    )

                VStack(spacing: 20) {
                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)

                    Text(NSLocalizedString("drop_file_here", comment: "Drop file here message"))
                        .font(.title2)
                        .foregroundColor(.gray)

                    Text(NSLocalizedString("or", comment: "Or text"))
                        .foregroundColor(.gray)

                    Button(NSLocalizedString("choose_file", comment: "Choose file button")) {
                        openFileDialog()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(40)
            }
            .frame(width: 400, height: 300)
            .onDrop(of: [.fileURL], isTargeted: $isDragging) { providers in
                handleDrop(providers: providers)
            }

            Spacer()
        }
        .onChange(of: appState.windowToOpen) { _, newValue in
            if let windowData = newValue {
                openWindow(id: "inspector", value: windowData)
                appState.windowToOpen = nil
            }
        }
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }

        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
            guard let data = item as? Data,
                  let url = URL(dataRepresentation: data, relativeTo: nil)
            else {
                return
            }

            DispatchQueue.main.async {
                appState.openInspectorWindow(for: url)
            }
        }

        return true
    }

    private func openFileDialog() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = true

        if panel.runModal() == .OK, let url = panel.url {
            appState.openInspectorWindow(for: url)
        }
    }
}

#Preview {
    OpenFileView()
        .environmentObject(AppState())
}
