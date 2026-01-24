# Xattr Editor

![Platform](https://img.shields.io/badge/macOS-14+-orange.svg)
![Xcode](https://img.shields.io/badge/Xcode-15+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5+-lavender.svg)

<img  src="Images/Appicon-64.png" width="64px">

## SwiftUI Version

This project has been migrated from XIB storyboard to SwiftUI, providing a modern UI framework with Liquid Glass effect support for macOS 15+. The app now requires:

- **Xcode 15** or later
- **macOS 14.0** or later
- **Swift 5.9**

## Preface

Xattr Editor is a simple GUI application to view/edit extended file attributes on macOS, for those users who might find a graphical interface more convenient—where they can drag and drop a file and view its extended attributes—rather than opening Terminal and interacting with `xattr`. With the added advantage that attributes can be edited one by one, adding, modifying, or deleting any of them.

The drawback of Xattr Editor is that, as an application downloaded from the internet, it also displays the Gatekeeper warning on its first run. This is unavoidable since the app is only ad-hoc signed and not notarized. This doesn't happen if you download the source code, compile the app using Xcode, and save the product for regular use.

This [document](DOCS/App-damaged.md) expands on the information about the security warning in files downloaded from the Internet, and 3 ways to fix it: Security and Privacy, `xattr` command line tool and **Xattr Editor**.
 
## Xattr Editor how-to 

It's really simple to use. When you start the app, a window appears where you can drag and drop files.

| Drop file window | 
|:----|
| ![Drop window no Liquid Glass](Images/App1-14.png) |
| ![Drop window Liquid Glass](Images/App1.png) |

You can also use the File >> Open menu (Cmd + O), which allows you to select a file instead of dragging it onto the window. Either way, the main window opens with the extended attribute(s) (if any) and their properties.

| Attributes window | 
|:----|
| ![Attributes window no Liquid Glass](Images/App2-14.png) |
| ![Attributes window Liquid Glass](Images/App2.png) |

You can add, rename, delete, or modify properties of existing attributes.

When removing an attribute, the user receives feedback.

**Note**: first screenshot is taken on Sonoma (no Liquid Glass), second on Tahoe (Liquid Glass support).

### Liquid Glass Support

The app includes Liquid Glass (translucent material) effect support for macOS 15 (Sequoia) and later, including macOS 26 (Tahoe) while maintaining full backward compatibility with macOS 14.

### Language selector

![Languages](Images/Language.png)

## Credits

*rcsiko* is the author of the original repository [xattr-editor](https://github.com/rcsiko/xattr-editor), which hasn't been updated in 7 years. I've created my own repository based on the original, which contains the most important part of the source code.  

Changelog oy my additions:

- Add app icon in Assets.xcassets
- Fix `swiftlint` warnings and refactor Swift code
- Migrate storyboard project to SwiftUI
- Add user feedback (alert) for attribute removal
- Fix error warning in attribute renaming
- Clear the attribute value field when deleting attributes
- Re-show drop file window when closing attribute inspector
- Improve README and documentation
- Update screenshots
- Add language support: German, English, Spanish, French and Italian  (default to English)
- Added language selector
- Add Liquid Glass support for macOS 15+ with backward compatibility for macOS 14.
