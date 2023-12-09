import SwiftUI
import UIKit

// Define the WorkoutView
struct WorkoutView: View {
    @State private var showActionSheet = false
    @State private var gradientRotation: Double = 0
    @State private var showingWorkoutBuilder = false // Added state for showing WorkoutBuilderView
    let gradientColors = [ColorSchemeManager.shared.currentColorScheme.med, ColorSchemeManager.shared.currentColorScheme.light]
    @State private var workouts: [Workout] = [] // Array to hold workouts

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

            VStack {
                WorkoutPlanCardView()
                header
                workoutCards
                Spacer()
            }                       .padding()
                       .clipShape(RoundedRectangle(cornerRadius: 30))
                       .sheet(isPresented: $showingWorkoutBuilder) {
                           WorkoutBuilderView(isPresented: self.$showingWorkoutBuilder)
                       }
                   }
                   .navigationBarTitle("", displayMode: .inline)
                   .onAppear {
                       fetchWorkouts()
            withAnimation(Animation.linear(duration: 8).repeatForever(autoreverses: false)) {
                gradientRotation = 360
            }
        }
    }
    
    private var workoutCards: some View {
        ScrollView {
            VStack {
                ForEach(workouts, id: \.workoutId) { workout in
                    WorkoutCardView(workout: workout)
                }
            }
        }
    }

    
    private var header: some View {
        HStack {
            Text("Workouts")
                .font(.largeTitle)
                .bold()
                .padding(.leading, 20)

            Spacer()

            Button(action: {
                            self.showingWorkoutBuilder = true
                        }) {
                            Image(systemName: "plus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                                .padding(13)
                                .foregroundColor(ColorSchemeManager.shared.currentColorScheme.med)
                                .background(.gray.opacity(0.05))
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
                    .padding(13)
                    .foregroundColor(ColorSchemeManager.shared.currentColorScheme.med)
                    .background(.gray.opacity(0.05))
                    .cornerRadius(15)
            }
            .sheet(isPresented: $showingWorkoutBuilder) {
                WorkoutBuilderView(isPresented: self.$showingWorkoutBuilder)
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
    private func fetchWorkouts() {
        // Retrieve the member ID and auth key from Keychain
        if let memberIdData = KeychainManager.load(service: "YourAppService", account: "userId"),
           let memberIdString = String(data: memberIdData, encoding: .utf8),
           let memberId = Int(memberIdString),
           let authKeyData = KeychainManager.load(service: "YourAppService", account: "authKey"),
           let authKey = String(data: authKeyData, encoding: .utf8) {

            print("Fetching workouts for memberId: \(memberId)")
            // Fetch workouts using NetworkManager
            NetworkManager.fetchWorkoutsForMember(memberId: memberId, authKey: authKey) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let fetchedWorkouts):
                        print("Successfully fetched workouts: \(fetchedWorkouts)")
                        self.workouts = fetchedWorkouts
                    case .failure(let error):
                        print("Error fetching workouts: \(error)")
                    }
                }
            }
        } else {
            print("Unable to retrieve member ID and/or auth key from Keychain")
        }
    }
}

// Preview for SwiftUI Canvas
struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutView()
    }
}
