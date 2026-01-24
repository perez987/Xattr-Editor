//
//  Material+LiquidGlass.swift
//  Xattr Editor
//
//  Liquid Glass material effect support for macOS 15+ (Sequoia/Tahoe)
//  with backward compatibility for macOS 14
//

import SwiftUI

// MARK: - Liquid Glass Material

/// Liquid Glass effect - translucent material with enhanced blur
/// Available on macOS 15.0 (Sequoia) and later, including macOS 26 (Tahoe)

@available(macOS 15.0, *)
extension Material {
    static var liquidGlass: Material {
        .ultraThinMaterial
    }
}

// MARK: - View Modifiers

/// Adaptive material background that applies Liquid Glass on macOS 15+
/// and falls back to standard backgrounds on macOS 14
struct AdaptiveMaterialBackground: ViewModifier {
    enum BackgroundType {
        case window
        case control
    }

    let type: BackgroundType

    func body(content: Content) -> some View {
        if #available(macOS 15.0, *) {
            content.background(Material.liquidGlass)
        } else {
            // Backward compatibility for macOS 14
            switch type {
            case .window:
                content.background(Color(nsColor: .windowBackgroundColor).opacity(0.95))
            case .control:
                content.background(Color(nsColor: .controlBackgroundColor))
            }
        }
    }
}

/// Window-level Liquid Glass effect using containerBackground
struct WindowLiquidGlassEffect: ViewModifier {
    func body(content: Content) -> some View {
        if #available(macOS 15.0, *) {
            content.containerBackground(Material.liquidGlass, for: .window)
        } else {
            content
        }
    }
}

// MARK: - View Extensions

extension View {
    /// Applies adaptive material background with Liquid Glass on macOS 15+ and standard background on macOS 14
    func adaptiveMaterialBackground(type: AdaptiveMaterialBackground.BackgroundType = .control) -> some View {
        modifier(AdaptiveMaterialBackground(type: type))
    }

    /// Applies window-level Liquid Glass effect on macOS 15+
    func windowLiquidGlass() -> some View {
        modifier(WindowLiquidGlassEffect())
    }
}
