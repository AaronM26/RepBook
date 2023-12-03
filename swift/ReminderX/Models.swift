import Foundation
import SwiftUI
import Combine

class AppViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
}

// Define the Workout data structure
struct Workout: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageName: String
    let requiresEquipment: Bool
    let duration: Int // Duration in minutes
    let caloriesBurned: Int
    // Add more properties as needed
}

// Define TagView for Workout Metadata
struct TagView: View {
    var text: String
    var color: Color

    var body: some View {
        Text(text)
            .font(.caption)
            .padding(5)
            .background(RoundedRectangle(cornerRadius: 10).fill(color.opacity(0.04)))
            .foregroundColor(color)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(color, lineWidth: 1)
            )
    }
}

class UserWorkouts: ObservableObject {
    @Published var workouts: [Workout] = []
    
    // Add functions to add, remove, or modify workouts
}

struct UserInfo: Decodable {
    var firstName: String
    var lastName: String
    var dateOfBirth: String
    var memberId: Int
    var heightCm: Int
    var weightKg: Int
    var benchMaxKg: Int
    var squatMaxKg: Int
    var bmi: Double
    var username: String
    var email: String // Added email property
}

struct Folder: Identifiable, Codable {
    var id = UUID()
    var name: String
    var color: CodableColor
    var reminders: [Reminder]
}

struct CodableColor: Codable {
    var color: Color

    enum CodingKeys: String, CodingKey {
        case color
    }

    init(color: Color) {
        self.color = color
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let colorData = try container.decode(String.self, forKey: .color)
        self.color = Color(hex: colorData) ?? Color.white
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
    }
}

struct Reminder: Identifiable, Codable {
    var id = UUID()
    var title: String
    var dueDate: Date
}
