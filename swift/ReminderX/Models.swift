import Foundation
import SwiftUI

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
