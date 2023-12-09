import Foundation
import SwiftUI


struct WorkoutCard: View {
    var workoutName: String
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(workoutName)
                .font(.title2)
                .bold()
                .foregroundColor(.gray)
            Button("Start") {
                // Action for start
            }
            .buttonStyle(GrayscalePrimaryButtonStyle())
            .frame(maxWidth: .infinity) // Button takes the width of the container
        }
        .padding()
        .background(Color.white) // No shadow for a blended look
    }
}

struct GrayscalePrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity) // Make the button take up the whole width
            .background(configuration.isPressed ? Color.black.opacity(0.3) : Color.gray.opacity(0.05)) // Black background
            .foregroundColor(.black) // White text
            .cornerRadius(15)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0) // Optional: slight scale effect on press for feedback
    }
}

struct AchievementCard: View {
    let medals = ["achievement", "achievement (1)", "achievement (2)", "achievement (3)"]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Achievements")
                .font(.title2)
                .bold()
                .foregroundColor(.black)
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .overlay(
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 17) {
                        ForEach(medals, id: \.self) { medal in
                            Image(medal)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                        }
                    }
                    .padding()
                )
        }
        .padding()
        .background(Color.white)
    }
}

struct LeaderboardCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Leaderboard")
                .font(.title)
                .bold()
                .foregroundColor(.black)
            // Placeholder for leaderboard content
            Spacer()
            Button("See Rankings") {
                // Action to see full leaderboard
            }
            .buttonStyle(GrayscalePrimaryButtonStyle())
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color.white)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
}

extension View {
    func cardStyle() -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 5)
            .padding(.horizontal)
    }
}
