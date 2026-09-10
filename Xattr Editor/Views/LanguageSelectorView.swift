//
//  LanguageSelectorView.swift
//  Xattr Editor
//
//  Language selector view with flag emojis
//

import SwiftUI

struct LanguageItem: Identifiable {
    let id: String
    let code: String
    let name: String
    let flag: String

    init(code: String, name: String, flag: String) {
        id = code
        self.code = code
        self.name = name
        self.flag = flag
    }
}

struct LanguageSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedLanguage: String
    @State private var showRestartAlert = false
    private let initialLanguage: String

    // Available languages sorted by code
    private let languages: [LanguageItem] = [
        LanguageItem(code: "de", name: "Deutsch", flag: "🇩🇪"),
        LanguageItem(code: "en", name: "English", flag: "🇬🇧"),
        LanguageItem(code: "es", name: "Español", flag: "🇪🇸"),
        LanguageItem(code: "fr", name: "Français", flag: "🇫🇷"),
        LanguageItem(code: "it", name: "Italiano", flag: "🇮🇹")
    ]

    init() {
        // Load current language preference
        let currentLang = UserDefaults.standard.stringArray(forKey: "AppleLanguages")?
            .first?.components(separatedBy: "-").first
            ?? Locale.current.language.languageCode?.identifier
            ?? "en"
        _selectedLanguage = State(initialValue: currentLang)
        initialLanguage = currentLang
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(NSLocalizedString("language_selector_title", comment: "Language selector title"))
                .font(.title2)
                .foregroundStyle(.primary)
                .padding(.top)

            List(languages, selection: $selectedLanguage) { language in
                HStack {
                    Text(language.flag)
                        .font(.title2)
                    Text(language.name)
                        .font(.body)
                }
                .tag(language.code)
                .padding(.vertical, 4)
            }
            .frame(height: 212)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(colorScheme == .dark ? Color.white.opacity(0.22) : Color.white.opacity(0.4), lineWidth: 1)
            )
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(colorScheme == .dark ? Color.black.opacity(0.28) : Color.white.opacity(0.12))
            )

            HStack(spacing: 12) {
                Button(NSLocalizedString("cancel", comment: "Cancel button")) {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Button(NSLocalizedString("accept", comment: "Accept button")) {
                    // Only show alert if language actually changed
                    if selectedLanguage != initialLanguage {
                        saveLanguagePreference()
                        showRestartAlert = true
                    } else {
                        dismiss()
                    }
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(.bottom)
        }
        .padding()
        .frame(width: 280)
        .modernGlassPanel(cornerRadius: 18)
        .alert(
            NSLocalizedString("language_changed_title", comment: "Language changed alert title"),
            isPresented: $showRestartAlert
        ) {
            Button(NSLocalizedString("ok", comment: "OK button")) {
                dismiss()
            }
        } message: {
            Text(NSLocalizedString("language_changed_message", comment: "Language changed message"))
        }
        .modernWindowBackground()
    }

    private func saveLanguagePreference() {
        UserDefaults.standard.set([selectedLanguage], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
}

#Preview {
    LanguageSelectorView()
}
