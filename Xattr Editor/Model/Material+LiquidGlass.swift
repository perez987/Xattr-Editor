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

// MARK: - Modern Color Theme

extension Color {
    static let modernSurfaceTop = Color(nsColor: .windowBackgroundColor)
    static let modernSurfaceBottom = Color(nsColor: .underPageBackgroundColor)
    static let modernAccentSoft = Color(red: 0.57, green: 0.69, blue: 0.98)
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

/// Window-level Liquid Glass effect
struct WindowLiquidGlassEffect: ViewModifier {
    func body(content: Content) -> some View {
        if #available(macOS 15.0, *) {
            // Use Liquid Glass material for macOS 15+
            content.background(Material.liquidGlass)
        } else {
            // Fallback for macOS 14 - use ultraThinMaterial
            content.background(Material.ultraThinMaterial)
        }
    }
}

/// Glass-like rounded panel with soft stroke and shadow
struct ModernGlassPanel: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .adaptiveMaterialBackground(type: .control)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.48), .white.opacity(0.12)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.11), radius: 22, x: 0, y: 8)
    }
}

/// Soft gradient for window background
struct ModernWindowBackground: ViewModifier {
    func body(content: Content) -> some View {
        content.background(
            LinearGradient(
                colors: [.modernSurfaceTop, .modernSurfaceBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
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

    /// Applies a modern glass panel style
    func modernGlassPanel(cornerRadius: CGFloat = 18) -> some View {
        modifier(ModernGlassPanel(cornerRadius: cornerRadius))
    }

    /// Applies a soft gradient window background
    func modernWindowBackground() -> some View {
        modifier(ModernWindowBackground())
    }
}
