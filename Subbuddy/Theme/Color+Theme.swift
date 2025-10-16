import SwiftUI

extension Color {
    static let appAccent = Color("AccentColor")
    static let appBackground = Color("BackgroundColor")
}

extension ShapeStyle where Self == Color {
    static var appAccent: Color { .appAccent }
    static var appBackground: Color { .appBackground }
}
