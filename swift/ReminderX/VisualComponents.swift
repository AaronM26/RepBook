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

struct WeightEntryView: View {
    @Binding var weight: String
    @Binding var unit: WeightUnit

    var body: some View {
        HStack {
            TextField("Weight", text: $weight)
                .keyboardType(.decimalPad)
                .onChange(of: weight) { newValue in
                    let filtered = newValue.filter { "0123456789.".contains($0) }
                    weight = filtered
                }
                .frame(width: 80)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Picker("Unit", selection: $unit) {
                Text("lb").tag(WeightUnit.lbs)
                Text("kg").tag(WeightUnit.kg)
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 100)
        }
    }
}

struct HeightEntryView: View {
    @Binding var heightFeet: String
    @Binding var heightInches: String

    var body: some View {
        HStack {
            TextField("Feet", text: $heightFeet)
                .keyboardType(.numberPad)
                .onChange(of: heightFeet) { newValue in
                    let filtered = newValue.filter { "0123456789".contains($0) }
                    if let intValue = Int(filtered), intValue <= 9 {
                        heightFeet = filtered
                    } else {
                        heightFeet = String(filtered.prefix(1))
                    }
                }
                .frame(width: 50)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Text("ft")

            TextField("Inches", text: $heightInches)
                .keyboardType(.numberPad)
                .onChange(of: heightInches) { newValue in
                    let filtered = newValue.filter { "0123456789".contains($0) }
                    if let intValue = Int(filtered), intValue <= 12 {
                        heightInches = filtered
                    } else {
                        heightInches = String(filtered.prefix(2))
                    }
                }
                .frame(width: 50)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Text("in")
        }
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

struct WorkoutPreviewCardView: View {
    @Binding var workoutName: String
    @Binding var selectedExercises: [Exercise]
    let colorScheme = ColorSchemeManager.shared.currentColorScheme
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                // Workout Name Field
                TextField("Workout Name", text: $workoutName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()

                // Exercise Counter
                Text("\(selectedExercises.count) Exercises")
                    .foregroundColor(.gray)
                    .padding(.trailing)
            }
            .padding(5)
            // Exercises Preview
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(selectedExercises) { exercise in
                        ExerciseCardView(exercise: exercise, onRemove: {
                            if let index = selectedExercises.firstIndex(where: { $0.id == exercise.id }) {
                                selectedExercises.remove(at: index)
                            }
                        })
                    }
                }
            }
        }
        .padding()
    }
}

struct ExerciseCardView: View {
    var exercise: Exercise
    var onRemove: () -> Void
    @State private var reps: Int = 10 // Default reps
    let colorScheme = ColorSchemeManager.shared.currentColorScheme

    // Define constants for the desired width and height
    private let cardWidth: CGFloat = 270 // Example width, adjust as needed
    private let cardHeight: CGFloat = 100 // Example height, adjust as needed

    var body: some View {
        VStack(alignment: .leading) {
            // Title and Trash icon
            HStack {
                Text(exercise.name)
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                Button(action: onRemove) {
                    Image(systemName: "trash")
                        .foregroundColor(Color.gray)
                }
            }

            // Description
            Text(exercise.description)
                .font(.footnote)
                .foregroundColor(.gray)

            // Tags
            HStack {
                TagView(text: exercise.muscleGroup, color: colorScheme.med)
                TagView(text: exercise.difficulty, color: colorScheme.med)
                TagView(text: exercise.workoutType, color: colorScheme.med)
                if exercise.equipmentNeeded {
                    TagView(text: "Equipment", color: colorScheme.med)
                }
            }
        }
        .padding()
        .frame(width: cardWidth, height: cardHeight)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(15)
    }
}

struct WorkoutCardView: View {
    var workout: Workout // Assuming Workout struct holds workout details

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                // Workout Title
                Text(workout.workoutName)
                    .font(.title2)
                    .fontWeight(.bold)
                Menu {
                    Button("Edit", action: editWorkout)
                    Button("Delete", action: deleteWorkout)
                    Button("Rename", action: renameWorkout)
                } label: {
                    Image(systemName: "ellipsis")
                        .imageScale(.large)
                        .foregroundColor(.black)
                        .padding()
                }
            }

            Text("\(workout.exerciseIds.count) exercises")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity) // Makes the card take up the full width of the screen
        .background(Color.gray.opacity(0.05))
        .cornerRadius(15)
        .padding(.horizontal) // Adds padding on the sides for some space from screen edges
    }

    private func editWorkout() {
        // Implement edit workout functionality
    }

    private func deleteWorkout() {
        // Implement delete workout functionality
    }

    private func renameWorkout() {
        // Implement rename workout functionality
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

struct ExerciseCard: View {
    let exercise: Exercise
    let colorScheme = ColorSchemeManager.shared.currentColorScheme
    var onAdd: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(exercise.name)
                    .font(.headline)
            }

            Spacer()

            // Button placed outside the VStack but within the HStack
            Button(action: onAdd) {
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
                    .padding(9)
                    .foregroundColor(.black.opacity(0.7))
                    .cornerRadius(10)
            }
            .padding(.trailing, 10) // Add some trailing padding to align properly
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.gray.opacity(0.05)))
        .padding(.horizontal)
    }
}


struct CompressedExerciseCard: View {
    let exercise: Exercise

    var body: some View {
        VStack(alignment: .leading) {
            Text(exercise.name)
                .font(.headline)
            Text(exercise.muscleGroup)
                .font(.subheadline)
        }
        .padding()
        .frame(width: 150, height: 80)
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.gray.opacity(0.05)))
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
            return "gearshape.fill"
        default:
            return ""
        }
    }
}

