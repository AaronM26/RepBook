import Foundation
import SwiftUI

struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}

extension Color {
    static let offWhite = Color(red: 225 / 255, green: 225 / 255, blue: 235 / 255)
}

struct NeumorphicGraphCardView: View {
    var data: GraphData
    var colorScheme: (dark: Color, med: Color, light: Color)

    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .fill(Color.offWhite) // Card color
            .frame(width: 350, height: 350) // Card size
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10) // Dark shadow
            .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5) // Light shadow
            .overlay(
                LineGraph(data: data, colorScheme: colorScheme)
                    .padding(20) // Padding for the graph inside the card
            )
    }
}


struct WorkoutPlanCardView: View {
    let title: String = "ARM DAY" // Example title
    let day: Int = 4 // Example day
    let streakCount: Int = 14 // Example streak count
    let workouts: [String] = ["Push-Ups", "Pull-Ups", "Dumbbell Curls"] // Example workouts

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Day \(day)")
                        .font(.headline)
                        .foregroundColor(.gray)
                }

                Spacer()

                VStack {
                    Text("\(streakCount) Days")
                        .fontWeight(.semibold)
                    Text("Streak")
                        .font(.caption)
                }
                .padding(.trailing)
            }
            .padding()
            .padding(.horizontal)
            WorkoutPreviewScrollView(workouts: workouts)
        }
        .background(Color.gray.opacity(0.05))
        .cornerRadius(25)
        .padding(.horizontal)
    }
}

struct WorkoutPreviewScrollView: View {
    let workouts: [String]
    @State private var currentIndex: Int = 0
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(workouts.indices, id: \.self) { index in
                Text(workouts[index])
                    .font(.title2)
                    .fontWeight(.medium)
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .frame(height: 100)
        .onReceive(timer) { _ in
            withAnimation {
                currentIndex = (currentIndex + 1) % workouts.count
            }
        }
    }
}

// Define the Workout Card View
struct WorkoutCard: View {
    let workout: Workout
    var body: some View {
        HStack {
            Image(workout.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .clipped()
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 5) {
                Text(workout.title)
                    .font(.headline)

                Text(workout.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                HStack {
                    TagView(text: workout.requiresEquipment ? "Equipment" : "No Equipment",
                            color: ColorSchemeManager.shared.currentColorScheme.dark)
                    TagView(text: "\(workout.duration) min",
                            color: ColorSchemeManager.shared.currentColorScheme.dark)
                    TagView(text: "\(workout.caloriesBurned) kcal",
                            color: ColorSchemeManager.shared.currentColorScheme.dark)
                }
            }

            Spacer()
        }
        .padding() // Padding inside the card
        .background(RoundedRectangle(cornerRadius: 25).fill(Color.gray.opacity(0.05)))
        .padding(.horizontal) // Padding around the card, inside the scroll view
    }
}

struct CustomTabBar: View {
    @Binding var selection: Int

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<4) { index in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        selection = index
                    }
                }) {
                    VStack {
                        Image(systemName: tabImageName(for: index))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: selection == index ? 32 : 24, height: selection == index ? 32 : 24)
                            .foregroundColor(selection == index ? .black.opacity(0.7) : .gray.opacity(0.45))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 60)
        .background(
            VisualEffectBlur(blurStyle: .systemThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 19))
                .padding([.leading, .trailing], 20)
        )
        .padding(.bottom, 6)
    }
    
    func tabImageName(for index: Int) -> String {
        switch index {
        case 0:
            return "person.fill"
        case 1:
            return "figure.strengthtraining.traditional"
        case 2:
            return "message.fill"
        case 3:
            return "gear"
        default:
            return ""
        }
    }
}

