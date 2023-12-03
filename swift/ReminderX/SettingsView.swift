import SwiftUI
import Foundation

struct SettingsView: View {
    var userInfo: UserInfo
    @State private var height: Double = 170
    @State private var weight: Double = 70

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Settings")
                    .font(.title)
                    .bold()
                    .padding(.top, 10)
                
                settingsSection(title: "Personal Information", settings: personalInformationSettings())
                settingsSection(title: "Health Metrics", settings: healthMetricsSettings())
                settingsSection(title: "Workout Preferences", settings: workoutPreferencesSettings())
                settingsSection(title: "Nutrition", settings: nutritionSettings())
                settingsSection(title: "App Settings", settings: appSettings())
                
                Button(action: logOut) {
                    Text("Log Out")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .padding(.horizontal)
                        .background(Color.black.opacity(0.8))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
            }
        }
        .padding(.horizontal, 2)
    }

    private func personalInformationSettings() -> [SettingItem<AnyView>] {
        [
            SettingItem(iconName: "person.fill", title: "First Name", actionView: AnyView(Text(userInfo.firstName))),
            SettingItem(iconName: "person.fill", title: "Last Name", actionView: AnyView(Text(userInfo.lastName))),
            SettingItem(iconName: "envelope.fill", title: "Email", actionView: AnyView(Text(userInfo.email))),
            SettingItem(iconName: "calendar", title: "Date of Birth", actionView: AnyView(Text(userInfo.dateOfBirth))),
            // ... more personal information settings
        ]
    }

    private func healthMetricsSettings() -> [SettingItem<AnyView>] {
        [
            SettingItem(iconName: "figure.walk", title: "Gender", actionView: AnyView(Text("Male"))),
            SettingItem(iconName: "arrow.up.and.down", title: "Height", actionView: AnyView(Slider(value: $height, in: 100...250))),
            SettingItem(iconName: "scalemass.fill", title: "Weight", actionView: AnyView(Slider(value: $weight, in: 30...200))),
            SettingItem(iconName: "heart.fill", title: "Resting Heart Rate", actionView: AnyView(Text("70 BPM"))),
            // ... more health metrics settings
        ]
    }

    private func workoutPreferencesSettings() -> [SettingItem<AnyView>] {
        [
            SettingItem(iconName: "flame.fill", title: "Fitness Goal", actionView: AnyView(Text("Weight Loss"))),
            SettingItem(iconName: "clock.fill", title: "Preferred Workout Time", actionView: AnyView(Text("Morning"))),
            SettingItem(iconName: "location.fill", title: "Preferred Workout Location", actionView: AnyView(Text("Outdoor"))),
            // ... more workout preferences settings
        ]
    }

    private func nutritionSettings() -> [SettingItem<AnyView>] {
        [
            SettingItem(iconName: "leaf.fill", title: "Dietary Preferences", actionView: AnyView(Text("Vegetarian"))),
            SettingItem(iconName: "applelogo", title: "Daily Caloric Intake", actionView: AnyView(Text("2000 kcal"))),
            SettingItem(iconName: "cup.and.saucer.fill", title: "Water Intake Goal", actionView: AnyView(Text("2L"))),
            // ... more nutrition settings
        ]
    }

    private func appSettings() -> [SettingItem<AnyView>] {
        [
            SettingItem(iconName: "paintbrush.fill", title: "Theme Color", actionView: AnyView(Text("Blue"))),
            SettingItem(iconName: "gear", title: "Language", actionView: AnyView(Text("English"))),
            // ... more app settings
        ]
    }

    @ViewBuilder
       private func settingsSection(title: String, settings: [SettingItem<AnyView>]) -> some View {
           VStack(alignment: .leading, spacing: 0) {  // No spacing between items
               Text(title)
                   .font(.headline)
                   .padding(.vertical, 5)
                   .frame(maxWidth: .infinity, alignment: .leading)
                   .padding(.horizontal)

               ForEach(settings.indices, id: \.self) { index in
                   let isFirst = index == settings.startIndex
                   let isLast = index == settings.index(before: settings.endIndex)
                   SettingItemView(setting: settings[index], isFirst: isFirst, isLast: isLast)
               }
           }
           .padding(.horizontal)
       }
    // Your existing functions like changeName, changeUsername, logOut

    private func changeName() {
        // Logic to change the name
    }

    private func changeUsername() {
        // Logic to change the username
    }

    private func logOut() {
        // Implement without changing the value of isAuthenticated
    }
}

struct SettingItemView<Content: View>: View {
    var setting: SettingItem<Content>
    var isFirst: Bool
    var isLast: Bool

    var body: some View {
        HStack {
            Image(systemName: setting.iconName)
            Text(setting.title)
            Spacer()
            setting.actionView
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(15, corners: isFirst ? [.topLeft, .topRight] : isLast ? [.bottomLeft, .bottomRight] : [])
    }
}

// Helper extension for corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct SettingItem<Content: View>: Identifiable {
    var id = UUID()
    var iconName: String
    var title: String
    var actionView: Content
}
