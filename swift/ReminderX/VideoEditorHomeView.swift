import SwiftUI
import UIKit

// Define the WorkoutView
struct WorkoutView: View {
    @State private var showActionSheet = false
    @State private var gradientRotation: Double = 0
    @State private var workouts: [Workout] = [] // Example workouts data
    let gradientColors = [ColorSchemeManager.shared.currentColorScheme.med, ColorSchemeManager.shared.currentColorScheme.light]

    var body: some View {
        ZStack {
            // Moving Gradient Background
            RoundedRectangle(cornerRadius: 0)
                .fill(
                    AngularGradient(
                        gradient: Gradient(colors: gradientColors),
                        center: .center,
                        startAngle: .degrees(gradientRotation),
                        endAngle: .degrees(gradientRotation + 360)
                    )
                )
                .blur(radius: 70)
                .edgesIgnoringSafeArea(.all)

            // White Rounded Rectangle
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.2), radius: 10, x: -5, y: -5)
                .shadow(color: .gray.opacity(0.2), radius: 10, x: 5, y: 5)
                .padding(.horizontal)
                .padding(.bottom, 76)

            // Content
            VStack {
                WorkoutPlanCardView()
                header
                ScrollView {
                    ForEach(workouts) { workout in
                        WorkoutCard(workout: workout)
                    }
                }
                Spacer()
            }
            .padding()
            .clipShape(RoundedRectangle(cornerRadius: 30))
        }
        .navigationBarTitle("", displayMode: .inline)
        .onAppear {
            withAnimation(Animation.linear(duration: 8).repeatForever(autoreverses: false)) {
                gradientRotation = 360
            }
            loadWorkouts() // Load workouts data
        }
    }

    private var header: some View {
        HStack {
            Text("Workouts")
                .font(.largeTitle)
                .bold()
                .padding(.leading, 20)

            Spacer()

            // Plus Button - Navigate to WorkoutBuilder View
            Button(action: {
            }) {
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .padding()
                    .foregroundColor(ColorSchemeManager.shared.currentColorScheme.med)
                    .background(ColorSchemeManager.shared.currentColorScheme.med.opacity(0.2))
                    .cornerRadius(15)
            }

            // Pencil Button - Implement action for editing workout plan
            Button(action: {
                // Action for editing workout plan
            }) {
                Image(systemName: "pencil")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .padding()
                    .foregroundColor(ColorSchemeManager.shared.currentColorScheme.med)
                    .background(ColorSchemeManager.shared.currentColorScheme.med.opacity(0.2))
                    .cornerRadius(15)
            }
        }
        .padding([.top, .horizontal])
    }

    private func CircleButton(iconName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: iconName)
                .resizable()
                .frame(width: 16, height: 16)
                .foregroundColor(ColorSchemeManager.shared.currentColorScheme.med)
        }
        .frame(width: 36, height: 36)
        .background(ColorSchemeManager.shared.currentColorScheme.light.opacity(0.4))
        .clipShape(Circle())
        .padding(EdgeInsets(top: 10, leading: 5, bottom: 5, trailing: 5))
    }

    private func loadWorkouts() {
        // Load workouts from local data or network request
        // Example:
        workouts = [
            Workout(title: "Morning Yoga", subtitle: "Stretch and Tone", imageName: "yoga", requiresEquipment: false, duration: 30, caloriesBurned: 200),
                        Workout(title: "HIIT", subtitle: "High-Intensity Interval Training", imageName: "hiit", requiresEquipment: true, duration: 20, caloriesBurned: 300)
        ]
    }
}

// Define the WorkoutBuilder view
struct WorkoutBuilder: View {
    @Binding var isPresented: Bool
    @State private var numberOfWorkoutsPerWeek = 3

    var body: some View {
        VStack(spacing: 20) {
            Text("Create Your Workout Plan")
                .bold()
                .padding()

            Picker("Number of Workouts Per Week", selection: $numberOfWorkoutsPerWeek) {
                ForEach(1..<8) {
                    Text("\($0) workouts").tag($0)
                }
            }
            .pickerStyle(WheelPickerStyle())
            
            // Based on the selection, offer a list of workout splits
            // TODO: Implement workout split logic

            // Allow the user to select specific workouts for each type of workout
            // TODO: Implement workout selection logic
            
            Button("Save Workout Plan") {
                // TODO: Save the workout plan logic
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            Button("Cancel") {
                self.isPresented = false
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding(40) // Give some padding from the screen edges
    }
}
// Preview for SwiftUI Canvas
struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutView()
    }
}
