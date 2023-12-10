import SwiftUI
import UniformTypeIdentifiers
import SwiftUICharts
import AVKit
import Combine
import CoreImage.CIFilterBuiltins

struct AITool: Identifiable {
    let id = UUID()
    let title: String
    let description: String
}

struct HomeView: View {
    var userInfo: UserInfo
    var userMetrics: [MemberMetric]
    @State private var memberMetrics: MemberMetric?
    @State private var workouts: [Workout] = []
    @State private var blurBackground: Bool = false
    @State private var accentColor: Color = Color.pink
    @State private var showingQuickReminderSheet = false
    @Environment(\.colorScheme) var colorScheme
    @State private var currentPage = 0
    @State private var currentTabIndex = 0
    @State private var optionSize: [ColorSchemeOption: CGSize] = [:]
    @State private var currentTime = Date()
    @State private var isScrolled = false
    @State private var showColorOptions = false
    @AppStorage("userColorScheme") private var userColorSchemeRawValue: Int = ColorSchemeOption.multi1.rawValue
    let totalPages = 3
    let autoSwitchInterval: TimeInterval = 5
    private let cardHeight: CGFloat = 93
    private let cardShadowRadius: CGFloat = 5
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        let nameGreeting = " \(userInfo.firstName)"  // Use firstName from userInfo
        
        if hour >= 4 && hour < 12 {
            return "Good Morning" + nameGreeting
        } else if hour >= 12 && hour < 17 {
            return "Good Afternoon" + nameGreeting
        } else {
            return "Good Evening" + nameGreeting
        }
    }
    
    private var currentColorScheme: (dark: Color, med: Color, light: Color) {
        return ColorSchemeOption(rawValue: userColorSchemeRawValue)?.colors ?? (.darkMulti1, .medMulti1, .lightMulti1)
    }
    @State private var selectedCardIndex = 0
    @State private var gradientRotation: Double = 0
    let colorSchemes: [[Color]] = [
        [.darkColor, .medColor, .lightColor],
        [.darkBlue, .medBlue, .lightBlue],
        [.darkGreen, .medGreen, .lightGreen],
        [.darkOrange, .medOrange, .lightOrange],
        [.darkRed, .medRed, .lightRed],
        [.darkViolet, .medViolet, .lightViolet],
        [.darkPink, .medPink, .lightPink],
        [.darkMulti1, .medMulti1, .lightMulti1],
        [.darkMulti2, .medMulti2, .lightMulti2],
        [.darkMulti3, .medMulti3, .lightMulti3]
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 0)
                                .fill(
                                    AngularGradient(
                                        gradient: Gradient(colors: [currentColorScheme.dark, currentColorScheme.med, currentColorScheme.light]),
                                        center: .center,
                                        startAngle: .degrees(gradientRotation),
                                        endAngle: .degrees(gradientRotation + 360)
                                    )
                                )
                                .padding(.all, 0)
                                .blur(radius: 45)
                                .frame(height: 85)
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(greeting)
                                        .font(.system(size: 37, weight: .bold))
                                        .foregroundColor(colorScheme == .light ? .white : .black)
                                    
                                    HStack {
                                        Text("4 Day Streak")
                                            .font(.system(size: 20, weight: .medium))
                                            .foregroundColor(colorScheme == .light ? .white : .black)
                                    }
                                }
                                .padding(.leading, 30)
                                
                                Spacer()
                            }
                        }
                    }
                    .padding(.bottom, 0)
                    
                    
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
                            // The rest of your cards
                            ForEach(0..<1) { _ in
                                wrappedCardView {
                                    TripleHeightCardView(currentColorScheme: [currentColorScheme.dark, currentColorScheme.med, currentColorScheme.light], memberMetrics: $memberMetrics)
                                }
                                VStack(spacing: 20) {
                                    // Red card
                                    wrappedCardView {
                                        doubleHeightCardView(color: .white)
                                    }
                                    
                                    // Blue card
                                    wrappedCardView {
                                        NavigationLink(destination: WorkoutView()) {
                                            cardView(color: .white, text: "Workouts", subtext: "14 workouts saved")
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        wrappedCardView {
                            NavigationLink(destination: WorkoutView()) {
                                quadHeightCardView(selectedCardIndex: $selectedCardIndex, color: .blue, currentColorScheme: currentColorScheme)
                            }
                            .padding(.horizontal)
                            .padding(.bottom)
                            .padding(.top)
                        }
                        .padding(.horizontal)
                        .onAppear {
                            withAnimation(Animation.linear(duration: 8).repeatForever(autoreverses: false)) {
                                gradientRotation = 360
                            }
                        }
                        .blur(radius: showColorOptions ? 10 : 0) // Apply blur when showColorOptions is true
                        HStack {
                            ScrollView(.horizontal, showsIndicators: false) { // Use a horizontal ScrollView
                                HStack {
                                    ForEach(ColorSchemeOption.allCases, id: \.self) { option in
                                        colorButton(option: option)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                        .padding(.horizontal)
                        .blur(radius: showColorOptions ? 10 : 0) // Apply blur when showColorOptions is true
                        .padding(.bottom, 50) // Add bottom padding here
                        Spacer()
                        Spacer()
                    }
                }
            }
        }
    }
    private func wrappedCardView<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(5)
            .background(Color(.systemBackground))
            .cornerRadius(25)
            .shadow(color: Color.primary.opacity(0.1), radius: cardShadowRadius, x: 0, y: cardShadowRadius)
    }
    
    private func wrappedCardViewGraph<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(5)
            .background(Color.green)
            .cornerRadius(25)
            .shadow(color: Color.primary.opacity(0.1), radius: cardShadowRadius, x: 0, y: cardShadowRadius)
    }
    
    private func wrappedCardViewCalender<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(5)
            .cornerRadius(25)
            .shadow(color: Color.primary.opacity(0.1), radius: cardShadowRadius, x: 0, y: cardShadowRadius)
    }
    
    private func cardView(color: Color, text: String, subtext: String = "", action: (() -> Void)? = nil, doubleHeight: Bool = false, mainTextFontSize: CGFloat = 20, subTextFontSize: CGFloat = 14) -> some View {
        NavigationLink(destination: WorkoutView()) {
            VStack(alignment: .leading) {
                Text(text)
                    .font(.system(size: 20, weight: .bold))
                    .bold()
                    .italic()
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(subtext)
                    .font(.system(size: subTextFontSize, weight: .regular, design: .rounded))
                    .foregroundColor(.primary.opacity(0.4))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .frame(height: doubleHeight ? cardHeight * 2 : cardHeight)
            .background(Color(.systemBackground))
            .cornerRadius(20)
        }
    }
    
    let achievements: [Achievement] = [
        Achievement(id: 0, image: "achievement (1)", title: "Plan", subtitle: "Craft your first personalized workout plan and set the foundation for your fitness journey."),
        Achievement(id: 1, image: "achievement (2)", title: "Streak", subtitle: "Maintain a workout streak by hitting the gym or working out at home for several consecutive days."),
        Achievement(id: 2, image: "achievement (3)", title: "PR", subtitle: "Achieve a new personal record in any of your favorite exercises or workouts.")
    ]
    
    private func doubleHeightCardView(color: Color) -> some View {
        VStack(spacing: 10) {
            TabView {
                // Display the first workout if available
                if let firstWorkout = workouts.first {
                    WorkoutCard(workoutName: firstWorkout.workoutName)
                } else {
                    Text("No workouts available")
                }
                AchievementCard()
                LeaderboardCard()
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 150)
            
            // Page indicator
            HStack(spacing: 7) {
                ForEach(0..<min(achievements.count, 3), id: \.self) { index in
                    Circle()
                        .fill(index == currentTabIndex ? .black : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(color)
        .cornerRadius(20)
    }
    
    struct InfoCardView: View {
        var symbolName: String
        var title: String
        var subtitle: String
        var colorScheme: Color
        
        private let cardHeight: CGFloat = 65
        private let horizontalSpacing: CGFloat = 6// Adjust as needed

        var body: some View {
            HStack() {
                Image(systemName: symbolName)
                    .foregroundColor(colorScheme)
                    .font(Font.title)
                    .frame(width: cardHeight, alignment: .center) // Set width to align image centrally

                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                        .bold()
                        .foregroundColor(colorScheme)
                    
                    Text(subtitle)
                        .foregroundColor(colorScheme)
                }
                .frame(maxWidth: .infinity, alignment: .leading) // Ensure VStack takes up remaining space
            }
            .frame(maxWidth: .infinity, minHeight: cardHeight)
            .background(colorScheme.opacity(0))
            .shadow(color: Color.black.opacity(0), radius: 3, x: 0, y: 2) // Adjust the shadow as needed
        }
    }
    
    struct TripleHeightCardView: View {
        var currentColorScheme: [Color]
        @Binding var memberMetrics: MemberMetric?

        private let cardHeight: CGFloat = 65 // Example height for each InfoCardView
        private let verticalSpacing: CGFloat = 10 // Spacing between cards
        private let additionalPadding: CGFloat = 20 // Additional padding for the whole view

        var body: some View {
            VStack(spacing: verticalSpacing) {
                if let metrics = memberMetrics {
                    // Display actual data
                    InfoCardView(symbolName: "ruler", title: "\(metrics.heightCm) cm", subtitle: "Height", colorScheme: currentColorScheme[1])
                    InfoCardView(symbolName: "scalemass", title: "\(metrics.weightKgString) kg", subtitle: "Weight", colorScheme: currentColorScheme[1].opacity(0.85))
                    InfoCardView(symbolName: "person.fill", title: metrics.gender, subtitle: "Gender", colorScheme: currentColorScheme[1].opacity(0.7))
                    InfoCardView(symbolName: "flame.fill", title: "\(metrics.workoutFrequency)", subtitle: "Workouts/Week", colorScheme: currentColorScheme[1].opacity(0.55))
                } else {
                    // Display placeholder cards with loading animations
                    ForEach(0..<4, id: \.self) { _ in
                        InfoCardLoadingView(colorScheme: currentColorScheme[1])
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: totalHeight())
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [currentColorScheme[1], currentColorScheme[2]]),
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 6
                    )
            )
        }

        private func totalHeight() -> CGFloat {
            let totalCardHeight = CGFloat(4) * cardHeight
            let totalSpacing = CGFloat(3) * verticalSpacing
            return totalCardHeight + totalSpacing + additionalPadding
        }
    }

    struct InfoCardLoadingView: View {
        var colorScheme: Color
        private let cardHeight: CGFloat = 65

        var body: some View {
            HStack {
                LoadingAnimationView()
                    .frame(width: 30, height: 30)
                    .foregroundColor(colorScheme)
                
                VStack {
                    LoadingAnimationView()
                        .frame(height: 20)
                    LoadingAnimationView()
                        .frame(height: 20)
                }
            }
            .frame(maxWidth: .infinity, minHeight: cardHeight)
            .background(colorScheme.opacity(0))
        }
    }

    struct LoadingAnimationView: View {
        @State private var isAnimating = false
        private let cornerRadius: CGFloat = 10 // Adjust the corner radius as needed

        var body: some View {
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .cornerRadius(cornerRadius) // Apply rounded corners
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .scaleEffect(isAnimating ? 1.02 : 1.0)
                    .opacity(isAnimating ? 0.6 : 0.3)
                    .animation(Animation.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: isAnimating)
                    .onAppear {
                        isAnimating = true
                    }
            }
        }
    }
    private func quadHeightCardView(selectedCardIndex: Binding<Int>, color: Color, subtext: String = "", action: (() -> Void)? = nil, doubleHeight: Bool = false, mainTextFontSize: CGFloat = 20, subTextFontSize: CGFloat = 14, currentColorScheme: (dark: Color, med: Color, light: Color)) -> some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            aiToolCardView(selectedCardIndex: selectedCardIndex, currentColorScheme: currentColorScheme)
                .frame(maxWidth: .infinity)
            cardSelector(selectedCardIndex: selectedCardIndex, currentColorScheme: currentColorScheme)
        }
    }
    
    private func cardSelector(selectedCardIndex: Binding<Int>, currentColorScheme: (dark: Color, med: Color, light: Color)) -> some View {
        HStack {
            let cardTitles = ["Metrics", "Strength", "Friends"]
            ForEach(0..<cardTitles.count, id: \.self) { index in
                Button(action: {
                    withAnimation {
                        selectedCardIndex.wrappedValue = index
                    }
                }) {
                    Text(cardTitles[index])
                        .font(.system(size: 18))
                        .padding(.vertical, 12)
                        .padding(.horizontal, 15)
                        .background(selectedCardIndex.wrappedValue == index ? currentColorScheme.med.opacity(0.05) : Color.clear)
                        .foregroundColor(selectedCardIndex.wrappedValue == index ? currentColorScheme.med : .black.opacity(0.5))
                        .cornerRadius(17)
                }
            }
        }
    }
    
    // Example usage in the aiToolCardView
    private func aiToolCardView(selectedCardIndex: Binding<Int>, currentColorScheme: (dark: Color, med: Color, light: Color)) -> some View {
        let exampleData: [(title: String, number: Int)] = [
            ("Strength", 200),
            ("Endurance", 150),
            ("Flexibility", 100)
        ]
        
        return CustomGraphCardView(titleNumberPairs: exampleData, currentColorScheme: currentColorScheme)
    }
    
    private func fetchWorkouts() {
        if let memberIdData = KeychainManager.load(service: "YourAppService", account: "userId"),
           let memberIdString = String(data: memberIdData, encoding: .utf8),
           let memberId = Int(memberIdString),
           let authKeyData = KeychainManager.load(service: "YourAppService", account: "authKey"),
           let authKey = String(data: authKeyData, encoding: .utf8) {

            print("Fetching workouts for: \(memberId)")
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
    private func fetchMemberMetrics() {
        // Retrieve the member ID and auth key from Keychain
        if let memberIdData = KeychainManager.load(service: "YourAppService", account: "userId"),
           let memberIdString = String(data: memberIdData, encoding: .utf8),
           let memberId = Int(memberIdString),
           let authKeyData = KeychainManager.load(service: "YourAppService", account: "authKey"),
           let authKey = String(data: authKeyData, encoding: .utf8) {

            print("Fetching member metrics for memberId: \(memberId)")
            // Fetch member metrics using NetworkManager
            NetworkManager.fetchMemberMetrics(memberId: memberId, authKey: authKey) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let fetchedMetrics):
                        print("Successfully fetched member metrics: \(fetchedMetrics)")
                        self.memberMetrics = fetchedMetrics.first // Assuming you want the first record
                    case .failure(let error):
                        print("Error fetching member metrics: \(error)")
                        // Handle the error accordingly
                    }
                }
            }
        } else {
            print("Unable to retrieve member ID and/or auth key from Keychain")
        }
    }
    private func colorButton(option: ColorSchemeOption) -> some View {
        Button(action: {
            withAnimation {
                userColorSchemeRawValue = option.rawValue
            }
        }) {
            ZStack {
                Circle()
                    .fill(AngularGradient(
                        gradient: Gradient(colors: [option.colors.dark, option.colors.med, option.colors.light, option.colors.med]),
                        center: .center
                    ))
                    .blur(radius: 6)
                    .frame(width: userColorSchemeRawValue == option.rawValue ? 45 : 35, height: userColorSchemeRawValue == option.rawValue ? 45 : 35)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(option.colors.light, lineWidth: 2)
                            .blur(radius: 4)
                            .offset(x: -2, y: -2)
                            .mask(Circle())
                    )
                    .overlay(
                        Circle()
                            .stroke(option.colors.dark, lineWidth: 2)
                            .blur(radius: 10)
                            .offset(x: 2, y: 2)
                            .mask(Circle())
                    )
                    .scaleEffect(optionSize[option, default: CGSize(width: 35, height: 35)].width / 35)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            if userColorSchemeRawValue == option.rawValue {
                                optionSize[option] = CGSize(width: 35, height: 35)
                                userColorSchemeRawValue = ColorSchemeOption.newColor.rawValue
                            } else {
                                optionSize[option] = CGSize(width: 35, height: 35)
                                userColorSchemeRawValue = option.rawValue
                            }
                        }
                    }
            }
        }
        .padding(9)
        .onAppear {
            fetchMemberMetrics()
            fetchWorkouts()
            if userColorSchemeRawValue == option.rawValue {
                DispatchQueue.main.async {
                    optionSize[option] = CGSize(width: 35, height: 35)
                }
            }
        }
    }
}

extension Color {
    func withBrightness(_ brightness: CGFloat) -> Color {
        let uiColor = UIColor(self)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightnessComponent: CGFloat = 0
        var alpha: CGFloat = 0

        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightnessComponent, alpha: &alpha)
        return Color(UIColor(hue: hue, saturation: saturation, brightness: min(brightnessComponent * brightness, 1.0), alpha: alpha))
    }
}

extension Color {
    // New color combination
    static let lightColor = Color(red: 0.12, green: 0.26, blue: 0.82)
    static let darkColor = Color(red: 0.38, green: 0.50, blue: 0.96)
    static let medColor = Color(red: 0.64, green: 0.78, blue: 0.96)

    // Blue
    static let darkBlue = Color(red: 0.88, green: 0.14, blue: 0.59)
    static let medBlue = Color(red: 0.94, green: 0.25, blue: 0.25)
    static let lightBlue = Color(red: 0.89, green: 0.75, blue: 0.73)


    // Green
    static let darkGreen = Color(red: 0.18, green: 0.80, blue: 0.44)
    static let medGreen = Color(red: 0.06, green: 0.53, blue: 0.06)
    static let lightGreen = Color(red: 0.78, green: 0.88, blue: 0.78)

    // Orange
    static let darkOrange = Color(red: 0.96, green: 0.09, blue: 0.00)
    static let medOrange = Color(red: 1.00, green: 0.75, blue: 0.36)
    static let lightOrange = Color(red: 0.79, green: 0.45, blue: 0.59)

    // Red
    static let darkRed = Color(red: 0.61, green: 0.04, blue: 0.08)
    static let medRed = Color(red: 0.96, green: 0.20, blue: 0.07)
    static let lightRed = Color(red: 0.99, green: 0.67, blue: 0.71)

    // Violet
    static let darkViolet = Color(red: 0.22, green: 0.02, blue: 0.34)
    static let medViolet = Color(red: 0.57, green: 0.19, blue: 0.54)
    static let lightViolet = Color(red: 0.90, green: 0.56, blue: 0.94)

    // Pink
    static let darkPink = Color(red: 0.80, green: 0.08, blue: 0.35)
    static let medPink = Color(red: 0.98, green: 0.43, blue: 0.70)
    static let lightPink = Color(red: 1.0, green: 0.83, blue: 0.92)
    
    // Multi-color 1: Blue to Purple Gradient
    static let darkMulti1 = Color(red: 0.114, green: 0.114, blue: 0.522)
    static let medMulti1 = Color(red: 0.427, green: 0.114, blue: 0.522)
    static let lightMulti1 = Color(red: 0.831, green: 0.114, blue: 0.522)

    // Multi-color 2: Pink to Orange Gradient
    static let darkMulti2 = Color(red: 1.000, green: 0.408, blue: 0.561)
    static let medMulti2 = Color(red: 1.000, green: 0.627, blue: 0.314)
    static let lightMulti2 = Color(red: 1.000, green: 0.863, blue: 0.314)

    // Multi-color 3: Green to Yellow Gradient
    static let darkMulti3 = Color(red: 0.204, green: 0.584, blue: 0.506)
    static let medMulti3 = Color(red: 0.620, green: 0.910, blue: 0.361)
    static let lightMulti3 = Color(red: 0.984, green: 0.973, blue: 0.420)
}
