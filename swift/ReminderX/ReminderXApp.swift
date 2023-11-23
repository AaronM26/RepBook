import SwiftUI

@main
struct ReminderXApp: App {
    @StateObject private var viewModel = ReminderXViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
