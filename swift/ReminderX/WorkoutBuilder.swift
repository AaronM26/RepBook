import Foundation
import SwiftUI

struct WorkoutBuilderView: View {
    @Binding var isPresented: Bool
    @State private var exercises: [Exercise] = []
    @State private var selectedExercises: [Exercise] = []
    @State private var workoutName: String = "Workout #1"
    @State private var searchText: String = ""
    @State private var isLoading = true
    @State private var isEditingWorkoutName = false  // Added this line
    @State private var selectedMuscleGroup: String = "All"
    @State private var equipmentNeeded: Bool? = nil
    @State private var selectedDifficulty: String = "All"

     
    var body: some View {
        VStack {
            WorkoutPreviewCardView(workoutName: $workoutName, selectedExercises: $selectedExercises)

            // Save Button - Visible only if there are selected exercises
            if !selectedExercises.isEmpty {
                Button(action: {
                    // Retrieve the user ID and auth key from Keychain
                    if let memberIdData = KeychainManager.load(service: "YourAppService", account: "userId"),
                       let memberIdString = String(data: memberIdData, encoding: .utf8),
                       let memberId = Int(memberIdString),
                       let authKeyData = KeychainManager.load(service: "YourAppService", account: "authKey"),
                       let authKey = String(data: authKeyData, encoding: .utf8) {

                        // Extract exercise IDs from the selected exercises
                        let exerciseIds = selectedExercises.map { $0.id }

                        // Call the createWorkout function from NetworkManager
                        NetworkManager.createWorkout(memberId: memberId,
                                                     workoutName: workoutName,
                                                     exerciseIds: exerciseIds,
                                                     authKey: authKey) { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success:
                                    print("Workout saved successfully")
                                    // Close the view on success
                                    self.isPresented = false
                                case .failure(let error):
                                    print("Failed to save workout: \(error)")
                                    // Handle failure (e.g., show an error message)
                                }
                            }
                        }
                    } else {
                        print("Error: Member ID or Auth Key not found")
                        // Handle the error (e.g., show an error message)
                    }

                }) {
                    Text("Save Workout")
                        .fontWeight(.bold)
                        .foregroundColor(Color.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(20)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }



            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.05))
                .overlay(
                    VStack {
                        exercisesHeader
                        filtersView
                        exercisesList
                    }
                )
                .padding(.horizontal)
        }
        .onAppear(perform: loadExercises)
    }
    
    private var exercisesHeader: some View {
        VStack(alignment: .leading) {
            Text("Exercises")
                .font(.title)
                .bold()
            
            Text("\(exercises.count) Exercises Loaded")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            TextField("Search exercises", text: $searchText)
                .padding(10)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(15)
        }
        .padding(.horizontal)
        .padding(.top)
    }
    private var exercisesList: some View {
        Group {
            if isLoading {
                VStack {
                    Spacer() // This spacer will push the loading symbol downwards
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                        .scaleEffect(1.5)
                        .padding()
                    Spacer() // This spacer will ensure the loading symbol is centered
                }
            } else {
                ScrollView {
                    VStack(spacing: 15) { // Add spacing between items
                        ForEach(filteredExercises) { exercise in
                            ExerciseCard(exercise: exercise, onAdd: {
                                addExercise(exercise)
                            })
                        }
                    }
                    .padding(.bottom) 
                }
            }
        }
    }

    
    private var workoutPreview: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.gray.opacity(0.05))
            .frame(height: 50)
            .overlay(
                HStack {
                    if isEditingWorkoutName {
                        TextField("Workout #1", text: $workoutName)
                            .padding()
                    } else {
                        Text(workoutName)
                            .underline(true, color: Color.gray)
                            .onTapGesture {
                                self.isEditingWorkoutName = true
                            }
                    }
                }
            )
            .padding(.horizontal)
    }
    
    private func addExercise(_ exercise: Exercise) {
        if !selectedExercises.contains(where: { $0.id == exercise.id }) {
            selectedExercises.append(exercise)
        }
    }
    
    private func deleteExercise(at offsets: IndexSet) {
        selectedExercises.remove(atOffsets: offsets)
    }
    
    private func moveExercise(from source: IndexSet, to destination: Int) {
        selectedExercises.move(fromOffsets: source, toOffset: destination)
    }
    
    private func loadExercises() {
        NetworkManager.fetchExercises { fetchedExercises in
            DispatchQueue.main.async {
                self.exercises = fetchedExercises
                self.isLoading = false // Stop the loading animation
            }
        }
    }
    
    private var filteredExercises: [Exercise] {
        exercises.filter { exercise in
            (selectedMuscleGroup == "All" || exercise.muscleGroup == selectedMuscleGroup) &&
            (equipmentNeeded == nil || exercise.equipmentNeeded == equipmentNeeded) &&
            (selectedDifficulty == "All" || exercise.difficulty == selectedDifficulty) &&
            (searchText.isEmpty || exercise.name.localizedCaseInsensitiveContains(searchText))
        }
    }

    
    private var filtersView: some View {
        HStack {
            // Muscle Group Filter
            filterButton(
                symbol: "figure.walk", // SF Symbol for Muscle Group
                selection: $selectedMuscleGroup,
                options: ["All", "Triceps", "Biceps", "Upper Back", "Lower Back", "Abs", "Quads", "Calves", "Glutes"]
            )
            
            // Equipment Needed Filter
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.05))
                .overlay(
                    Toggle(isOn: equipmentNeededBinding) {
                        Image(systemName: "wrench.and.screwdriver") // SF Symbol for Equipment
                            .foregroundColor(.black)
                    }
                    .padding()
                )
                .frame(height: 44)
            
            // Difficulty Filter
            filterButton(
                symbol: "waveform.path.ecg", // SF Symbol for Difficulty
                selection: $selectedDifficulty,
                options: ["All", "Beginner", "Intermediate", "Advanced"]
            )
        }
        .padding(.horizontal)
    }

    private func filterButton<T: Hashable>(symbol: String, selection: Binding<T>, options: [T]) -> some View {
        Menu {
            Picker(selection: selection, label: Image(systemName: symbol)) {
                ForEach(options, id: \.self) { option in
                    Text("\(String(describing: option))") // Text representation of the option
                }
            }
        } label: {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.05))
                .overlay(
                    Image(systemName: symbol) // Display the SF Symbol
                        .foregroundColor(.black) // Set the symbol color to black
                        .padding()
                )
                .frame(height: 44)
        }
    }


    
    private var equipmentNeededBinding: Binding<Bool> {
        Binding<Bool>(
            get: { self.equipmentNeeded ?? false },
            set: { self.equipmentNeeded = $0 }
        )
    }
}
