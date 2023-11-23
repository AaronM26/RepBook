import SwiftUI

class ColorSchemeManager: ObservableObject {
    static let shared = ColorSchemeManager()
    
    private init() { }
    
    @Published var transitionDuration: Double = 0.45
    
    private var userColorSchemeRawValue: Int {
        get {
            return UserDefaults.standard.integer(forKey: "userColorScheme")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "userColorScheme")
        }
    }
    
    var currentColorScheme: (dark: Color, med: Color, light: Color) {
        return ColorSchemeOption(rawValue: userColorSchemeRawValue)?.colors ?? (.darkMulti1, .medMulti1, .lightMulti1)
    }
    
    func updateColorScheme(to newColorScheme: ColorSchemeOption) {
        withAnimation(.easeInOut(duration: self.transitionDuration)) {
            self.userColorSchemeRawValue = newColorScheme.rawValue
        }
    }
}

enum ColorSchemeOption: Int, CaseIterable {
    case system
    case red
    case orange
    case multi3
    case green
    case blue
    case violet
    case pink
    case newColor
    case multi1
    case multi2

    var colors: (dark: Color, med: Color, light: Color) {
        switch self {
        case .system:
            return (Color(.systemGray), Color(.black), Color(.systemGray2))
        case .red:
            return (ColorScheme.darkColor, ColorScheme.medColor, ColorScheme.lightColor)
        case .orange:
            return (ColorScheme.darkBlue, ColorScheme.medBlue, ColorScheme.lightBlue)
        case .multi3:
            return (ColorScheme.darkGreen, ColorScheme.medGreen, ColorScheme.lightGreen)
        case .green:
            return (ColorScheme.darkOrange, ColorScheme.medOrange, ColorScheme.lightOrange)
        case .blue:
            return (ColorScheme.darkRed, ColorScheme.medRed, ColorScheme.lightRed)
        case .violet:
            return (ColorScheme.darkViolet, ColorScheme.medViolet, ColorScheme.lightViolet)
        case .pink:
            return (ColorScheme.darkPink, ColorScheme.medPink, ColorScheme.lightPink)
        case .newColor:
            return (ColorScheme.darkMulti1, ColorScheme.medMulti1, ColorScheme.lightMulti1)
        case .multi1:
            return (ColorScheme.darkMulti2, ColorScheme.medMulti2, ColorScheme.lightMulti2)
        case .multi2:
            return (ColorScheme.darkMulti3, ColorScheme.medMulti3, ColorScheme.lightMulti3)
        }
    }
}

struct ColorScheme {
    // Red Group - Using a different shade of reds with adjusted tones for visual appeal
    static let darkColor = Color(red: 0.77, green: 0.10, blue: 0.15) // Darker shade of red
    static let medColor = Color(red: 0.95, green: 0.47, blue: 0.46) // Medium shade of red
    static let lightColor = Color(red: 0.99, green: 0.79, blue: 0.82) // Light shade of red

    // Orange Group - Enhanced coral to peach gradient
    static let darkBlue = Color(red: 0.99, green: 0.44, blue: 0.24) // Darker shade of orange
    static let medBlue = Color(red: 0.99, green: 0.65, blue: 0.49) // Medium shade of orange
    static let lightBlue = Color(red: 0.99, green: 0.87, blue: 0.79) // Light shade of orange

    // Yellow Group - From a richer amber to a warmer light yellow
    static let darkGreen = Color(red: 0.99, green: 0.76, blue: 0.03) // Darker shade of yellow
    static let medGreen = Color(red: 0.99, green: 0.86, blue: 0.38) // Medium shade of yellow
    static let lightGreen = Color(red: 0.99, green: 0.92, blue: 0.76) // Light shade of yellow

    // Green Group - A set of greens with a subtler touch of blue
    static let darkOrange = Color(red: 0.02, green: 0.70, blue: 0.20) // Darker shade of green
    static let medOrange = Color(red: 0.40, green: 0.85, blue: 0.49) // Medium shade of green
    static let lightOrange = Color(red: 0.70, green: 0.95, blue: 0.79) // Light shade of green

    // Blue Group - A slightly warmer cooler blue palette
    static let darkRed = Color(red: 0.20, green: 0.30, blue: 0.90) // Darker shade of blue
    static let medRed = Color(red: 0.45, green: 0.55, blue: 0.97) // Medium shade of blue
    static let lightRed = Color(red: 0.75, green: 0.85, blue: 0.99) // Light shade of blue

    // Indigo Group - More pronounced purples to lilac
    static let darkViolet = Color(red: 0.40, green: 0.20, blue: 0.70) // Darker shade of indigo
    static let medViolet = Color(red: 0.60, green: 0.45, blue: 0.85) // Medium shade of indigo
    static let lightViolet = Color(red: 0.85, green: 0.75, blue: 0.95) // Light shade of indigo

    // Violet Group - Enhanced pink shades with a touch more warmth
    static let darkPink = Color(red: 0.89, green: 0.20, blue: 0.60) // Darker shade of violet
    static let medPink = Color(red: 0.94, green: 0.50, blue: 0.75) // Medium shade of violet
    static let lightPink = Color(red: 0.97, green: 0.80, blue: 0.89) // Light shade of violet

    // Vibrant Group 1: Sunset colors from a deeper orange to a more intense warm yellow
    static let darkMulti1 = Color(red: 0.89, green: 0.30, blue: 0.11) // Darker shade of vibrant 1
    static let medMulti1 = Color(red: 0.99, green: 0.55, blue: 0.20) // Medium shade of vibrant 1
    static let lightMulti1 = Color(red: 0.99, green: 0.80, blue: 0.50) // Light shade of vibrant 1

    // Vibrant Group 2: Oceanic colors from a richer teal to a more delicate soft cyan
    static let darkMulti2 = Color(red: 0.11, green: 0.60, blue: 0.60) // Darker shade of vibrant 2
    static let medMulti2 = Color(red: 0.30, green: 0.80, blue: 0.80) // Medium shade of vibrant 2
    static let lightMulti2 = Color(red: 0.60, green: 0.90, blue: 0.90) // Light shade of vibrant 2

    // Vibrant Group 3: Berries blend from a more saturated purple to a softer lavender
    static let darkMulti3 = Color(red: 0.55, green: 0.10, blue: 0.60) // Darker shade of vibrant 3
    static let medMulti3 = Color(red: 0.70, green: 0.40, blue: 0.80) // Medium shade of vibrant 3
    static let lightMulti3 = Color(red: 0.85, green: 0.60, blue: 0.90) // Light shade of vibrant 3
}
