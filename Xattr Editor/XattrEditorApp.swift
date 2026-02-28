//
//  XattrEditorApp.swift
//  Xattr Editor
//
//  SwiftUI App Entry Point
//

import SwiftUI

@main
struct XattrEditorApp: App {
    @StateObject private var appState = AppState()
    @State private var isLanguageSelectorPresented = false

    var body: some Scene {
        // Main drop file window - always visible
        Window(NSLocalizedString("app_title", comment: "Application title"), id: "main") {
            OpenFileView()
                .environmentObject(appState)
                .frame(width: 500, height: 425)
                .windowLiquidGlass()
                .sheet(isPresented: $isLanguageSelectorPresented) {
                    LanguageSelectorView()
                }
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        .commands {
            CommandGroup(after: .appInfo) {
                // Settings to check for updates
                Button(NSLocalizedString("Check for Updates…", comment: "Menu item to check for app updates"),
                       systemImage: "arrow.triangle.2.circlepath")
                {
                    GitHubUpdateChecker.shared.checkForUpdates(userInitiated: true)
                }
                .keyboardShortcut("u", modifiers: [.command])
            }
            // Language menu before File menu
            CommandMenu(NSLocalizedString("menu_language", comment: "Language menu")) {
                Button(NSLocalizedString("menu_select_language", comment: "Select Language menu item")) {
                    isLanguageSelectorPresented = true
                }
                .keyboardShortcut("l", modifiers: .command)
            }

            CommandGroup(replacing: .newItem) {
                Button(NSLocalizedString("menu_open", comment: "Menu open command")) {
                    openFile()
                }
                .keyboardShortcut("o", modifiers: .command)
            }
        }

        // Inspector window group - for attribute inspectors
        WindowGroup(id: "inspector", for: InspectorWindowData.self) { $windowData in
            if let windowData {
                AttributeInspectorView(fileURL: windowData.fileURL, windowId: windowData.id)
                    .environmentObject(appState)
                    .windowLiquidGlass()
            }
        }
        .windowResizability(.contentSize)
    }

    private func openFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = true

        if panel.runModal() == .OK, let url = panel.url {
            // Create window data and notify the app to open it
            let windowData = InspectorWindowData(fileURL: url)
            appState.windowToOpen = windowData
        }
    }
}

class AppState: ObservableObject {
    @Published var windowToOpen: InspectorWindowData?

    func openInspectorWindow(for url: URL) {
        let windowData = InspectorWindowData(fileURL: url)
        windowToOpen = windowData
    }
}

struct InspectorWindowData: Identifiable, Hashable, Encodable, Decodable {
    let id: UUID
    let fileURL: URL

    init(fileURL: URL) {
        id = UUID()
        self.fileURL = fileURL
    }

    // Custom Codable implementation to handle URL
    enum CodingKeys: String, CodingKey {
        case id
        case filePath
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(fileURL.path, forKey: .filePath)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        let filePath = try container.decode(String.self, forKey: .filePath)
        fileURL = URL(fileURLWithPath: filePath)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: InspectorWindowData, rhs: InspectorWindowData) -> Bool {
        lhs.id == rhs.id
    }
}
