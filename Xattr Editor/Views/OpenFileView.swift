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
    @Environment(\.colorScheme) private var colorScheme
    @State private var isDragging = false

    var body: some View {
        VStack {
            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(
                            colors: [
                                colorScheme == .dark ? Color.black.opacity(0.35) : Color.white.opacity(0.26),
                                colorScheme == .dark
                                    ? Color.modernAccentSoft.opacity(0.16)
                                    : Color.modernAccentSoft.opacity(0.30)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .modernGlassPanel(cornerRadius: 22)

                RoundedRectangle(cornerRadius: 22)
                    .strokeBorder(
                        isDragging
                            ? Color.accentColor.opacity(0.95)
                            : (colorScheme == .dark ? Color.blue.opacity(0.05) : Color.blue.opacity(0.33)),
                        style: StrokeStyle(lineWidth: isDragging ? 4 : 2, dash: [10])
                    )

                VStack(spacing: 20) {
                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.modernAccentSoft, .accentColor],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    Text(NSLocalizedString("drop_file_here", comment: "Drop file here message"))
                        .font(.title2)
                        .foregroundStyle(.primary)

                    Text(NSLocalizedString("or", comment: "Or text"))
                        .foregroundStyle(.secondary)

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
        .modernWindowBackground()
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
