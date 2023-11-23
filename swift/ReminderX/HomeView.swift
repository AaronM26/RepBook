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
    @ObservedObject var viewModel: ReminderXViewModel
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
        
        if hour >= 4 && hour < 12 {
            return "Good Morning"
        } else if hour >= 12 && hour < 17 {
            return "Good Afternoon"
        } else {
            return "Good Evening"
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
                                .blur(radius: 35)
                                .frame(height: 95)
                            
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
                                    TripleHeightCardView(currentColorScheme: [currentColorScheme.dark, currentColorScheme.med, currentColorScheme.light])
                                }
                                VStack(spacing: 20) {
                                    // Red card
                                    wrappedCardView {
                                        doubleHeightCardView(color: .white, action: {
                                            showingQuickReminderSheet.toggle()
                                        })
                                    }
                                    
                                    // Blue card
                                    wrappedCardView {
                                        NavigationLink(destination: VideoEditorHomeView()) {
                                            cardView(color: .white, text: "Workouts", subtext: "14 workouts saved")
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        Spacer()
                        Spacer()
                        Spacer()
                    
                        wrappedCardView {
                            NavigationLink(destination: VideoEditorHomeView()) {
                                quadHeightCardView(selectedCardIndex: $selectedCardIndex, color: .blue, currentColorScheme: currentColorScheme)
                            }
                            .padding(.horizontal)
                            .padding(.bottom)
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
        NavigationLink(destination: VideoEditorHomeView()) {
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

    private func doubleHeightCardView(color: Color, action: (() -> Void)? = nil) -> some View {
        Button(action: {
            // existing action code
        }) {
            VStack(alignment: .leading, spacing: 10) { // Maintain the overall spacing
                TabView(selection: $currentTabIndex) {
                    VStack(spacing: 10) { // Adjust individual spacing if needed
                        Image(systemName: "figure.run")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 50)
                            .foregroundColor(currentColorScheme.light)
                        Text("Personal Training")
                            .bold()
                            .font(.title)
                            .foregroundColor(currentColorScheme.med)
                            .fixedSize(horizontal: false, vertical: true) // Allows text to wrap
                            .lineLimit(2) // Limits to two lines
                    }.tag(0)
                    
                    VStack(spacing: 4) { // Adjust individual spacing if needed
                        
                        Image(systemName: "person.3.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 50)
                            .scaleEffect(0.7)
                            .foregroundColor(currentColorScheme.light)
                        Text("Group Sessions")
                            .bold()
                            .font(.title)
                            .foregroundColor(currentColorScheme.med)
                            .fixedSize(horizontal: false, vertical: true) // Allows text to wrap
                            .lineLimit(2) // Limits to two lines
                    }.tag(1)
                    
                    VStack(spacing: 10) { // Adjust individual spacing if neede
                        Image(systemName: "dumbbell.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .scaleEffect(0.7)
                            .frame(height: 50)
                            .foregroundColor(currentColorScheme.light)
                        Text("Competition")
                            .bold()
                            .font(.title)
                            .foregroundColor(currentColorScheme.med)
                            .fixedSize(horizontal: false, vertical: true) // Allows text to wrap
                            .lineLimit(2) // Limits to two lines
                    }.tag(2)
                }
                .frame(height: 140)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Page indicator
                HStack {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(index == currentTabIndex ? currentColorScheme.med : Color.gray.opacity(0.5))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.vertical, 5) // Maintains padding around the dots
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding()
            .frame(minHeight: cardHeight * 2 + 20) // Adjusted for potential increase in content due to text wrapping
            .background(Color(.systemBackground))
            .cornerRadius(20)
        }
    }
    
    struct DataBarView: View {
        var value: CGFloat  // This will represent the percentage of the bar that's filled
        var maxValue: CGFloat = 100 // This represents the maximum possible value, for scaling purposes
        var currentColorScheme: [Color]

        var body: some View {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width , height: 8)
                        .opacity(0.3)
                        .foregroundColor(currentColorScheme[1].opacity(0.3))
                        .cornerRadius(7.5)
                    
                    Rectangle()
                        .frame(width: (geometry.size.width * value / maxValue), height: 10)
                        .foregroundColor(currentColorScheme[2])
                        .cornerRadius(5.5)
                }
            }
        }
    }

    struct TripleHeightCardView: View {
        var currentColorScheme: [Color]

        private let cardHeight: CGFloat = 92
        private let titleSize: CGFloat = 32 // Updated size for member name text
        
        let heightData = (value: "5'11\"", change: "+2%")
        let weightData = (value: "190lb", change: "-1%")

        @State private var workoutFrequency: CGFloat = 3
        @State private var workoutLength: CGFloat = 45
        @State private var averageKcal: CGFloat = 500

        var body: some View {
            VStack {
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Workout Frequency")
                            .font(.footnote)
                            .fontWeight(.bold)
                        DataBarView(value: workoutFrequency, maxValue: 7, currentColorScheme: currentColorScheme)
                            .frame(height: 7)

                        Text("Workout Length")
                            .font(.footnote)
                            .fontWeight(.bold)
                        DataBarView(value: workoutLength, maxValue: 120, currentColorScheme: currentColorScheme)
                            .frame(height: 7)

                        Text("Average kcal")
                            .font(.footnote)
                            .fontWeight(.bold)
                        DataBarView(value: averageKcal, maxValue: 1000, currentColorScheme: currentColorScheme)
                            .frame(height: 7)
                    }
                    VStack() {
                                        // Height Card
                                        VStack {
                                            Text(heightData.value)
                                                .font(.headline)
                                                .bold()
                                                .foregroundColor(currentColorScheme[1]) // Using .dark from your color scheme

                                            Text(heightData.change)
                                                .foregroundColor(currentColorScheme[1]) // Using .dark from your color scheme
                                        }
                                        .frame(maxWidth: .infinity, minHeight: 65)
                                        .background(currentColorScheme[1].opacity(0.1))
                                        .cornerRadius(15)

                                        // Weight Card
                                        VStack {
                                            Text(weightData.value)
                                                .font(.headline)
                                                .bold()
                                                .foregroundColor(currentColorScheme[1]) // Using .dark from your color scheme
                                            Text(weightData.change)
                                                .foregroundColor(currentColorScheme[1]) // Using .dark from your color scheme
                                        }
                                        .frame(maxWidth: .infinity, minHeight: 65)
                                        .background(currentColorScheme[1].opacity(0.1))
                                        .cornerRadius(15)
                                    }
                                    .frame(maxHeight: .infinity)
                                }
                                .padding()
                                .frame(maxHeight: .infinity) // This will ensure the VStack takes the full height of its parent
            }
            .frame(height: cardHeight * 3 + 55)
            .frame(maxWidth: .infinity)
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
                        lineWidth: 6.4
                    )
            )
        }
    }


    struct TitleSliderPair: View {
        var title: String
        @Binding var value: Double
        var range: ClosedRange<Double>
        
        var body: some View {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.footnote)
                    .fontWeight(.bold)
                Slider(value: $value, in: range)
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
                        .font(.system(size: 17))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                        .background(selectedCardIndex.wrappedValue == index ? currentColorScheme.med.opacity(0.05) : Color.clear)
                        .foregroundColor(selectedCardIndex.wrappedValue == index ? currentColorScheme.med : .black.opacity(0.5))
                        .cornerRadius(15)
                }
            }
        }
    }

    struct CustomGraphCardView: View {
        var titleNumberPairs: [(title: String, number: Int)]
        var currentColorScheme: (dark: Color, med: Color, light: Color)

        var body: some View {
            HStack {
                // Left side (30%)
                VStack(alignment: .leading, spacing: 13) {
                    ForEach(titleNumberPairs, id: \.title) { pair in
                        VStack(alignment: .leading, spacing: 0) {
                            Text(pair.title)
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            Text("\(pair.number)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(currentColorScheme.med)
                                .italic()
                        }
                    }
                }
                .frame(width: UIScreen.main.bounds.width * 0.17)
                .padding(.vertical) // Adds vertical spacing

                // Right side (70%)
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(currentColorScheme.med.opacity(0.05))
                        .shadow(color: currentColorScheme.dark.opacity(0.1), radius: 3, x: -5, y: -5)
                        .shadow(color: currentColorScheme.light.opacity(0.1), radius: 3, x: 5, y: 5)

                    // Replace this with the real graph data you have
                    let exampleGraphData = GraphData(points: [10, 20, 15, 30, 25, 30, 15, 20, 10])
                    
                    // Updated Line Graph
                    LineGraph(data: exampleGraphData, colorScheme: currentColorScheme)
                }
                .frame(width: UIScreen.main.bounds.width * 0.63)
                .frame(height: UIScreen.main.bounds.height * 0.25)
                .padding(.vertical) // Adds vertical spacing
            }
        }
    }

    struct GraphData {
        var points: [CGFloat] // Raw data points
        
        // Normalize a single data point to fit within the graph's bounds
        func normalizedPoint(index: Int, frame: CGRect) -> CGPoint {
            let xPosition = frame.width * CGFloat(index) / CGFloat(points.count - 1)
            let yPosition = (1 - (points[index] - minValue) / (maxValue - minValue)) * frame.height
            return CGPoint(x: xPosition, y: yPosition)
        }
        
        // Compute the maximum and minimum data values for scaling
        var maxValue: CGFloat { points.max() ?? 0 }
        var minValue: CGFloat { points.min() ?? 0 }
        
        // Find the indices of the peak and valley points for labeling
        var peakIndex: Int? { points.indices.max(by: { points[$0] < points[$1] }) }
        var valleyIndex: Int? { points.indices.max(by: { points[$0] > points[$1] }) }
    }

    struct GraphGrid: View {
        var data: GraphData
        var body: some View {
            GeometryReader { geometry in
                Path { path in
                    // Draw the horizontal grid lines
                    for i in 0...4 {
                        let y = geometry.size.height * CGFloat(i) / 4
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                }
                .stroke(Color.gray.opacity(0.3))
                
                // Vertical lines
                Path { path in
                    for i in 0..<data.points.count {
                        let x = geometry.size.width * CGFloat(i) / CGFloat(data.points.count - 1)
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                    }
                }
                .stroke(Color.gray.opacity(0.3))
            }
        }
    }

    struct GraphLine: View {
        var data: GraphData
        var colorScheme: (dark: Color, med: Color, light: Color)
        
        var body: some View {
            GeometryReader { geometry in
                Path { path in
                    let firstPoint = data.normalizedPoint(index: 0, frame: geometry.frame(in: .local))
                    path.move(to: firstPoint)
                    for index in data.points.indices {
                        let nextPoint = data.normalizedPoint(index: index, frame: geometry.frame(in: .local))
                        path.addLine(to: nextPoint)
                    }
                }
                .stroke(colorScheme.light, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            }
        }
    }

    struct GraphPoints: View {
        var data: GraphData
        var colorScheme: (dark: Color, med: Color, light: Color)
        
        var body: some View {
            GeometryReader { geometry in
                ForEach(data.points.indices, id: \.self) { index in
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(colorScheme.dark)
                        .position(data.normalizedPoint(index: index, frame: geometry.frame(in: .local)))
                }
                if let peakIndex = data.peakIndex {
                    Text("\(data.points[peakIndex], specifier: "%.1f")")
                        .offset(x: data.normalizedPoint(index: peakIndex, frame: geometry.frame(in: .local)).x,
                                y: data.normalizedPoint(index: peakIndex, frame: geometry.frame(in: .local)).y - 20)
                }
                if let valleyIndex = data.valleyIndex {
                    Text("\(data.points[valleyIndex], specifier: "%.1f")")
                        .offset(x: data.normalizedPoint(index: valleyIndex, frame: geometry.frame(in: .local)).x,
                                y: data.normalizedPoint(index: valleyIndex, frame: geometry.frame(in: .local)).y + 10)
                }
            }
        }
    }

    struct LineGraph: View {
        var data: GraphData
        var colorScheme: (dark: Color, med: Color, light: Color)
        
        var body: some View {
            ZStack {
                GraphGrid(data: data)
                GraphLine(data: data, colorScheme: colorScheme)
                GraphPoints(data: data, colorScheme: colorScheme)
            }
            .clipped()
            .padding(.horizontal, 15)
            .padding(.vertical, 15)
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
        .padding(8)
        .onAppear {
            if userColorSchemeRawValue == option.rawValue {
                // Set the initial size for the selected color
                DispatchQueue.main.async {
                    optionSize[option] = CGSize(width: 35, height: 35)
                }
            }
        }
    }


    private func remindersComingUp() -> Int {
        let now = Date()
        let calendar = Calendar.current
        let fiveDaysLater = calendar.date(byAdding: .day, value: 5, to: now) ?? now
        
        var count = 0
        for folder in viewModel.folders {
            for reminder in folder.reminders {
                if reminder.dueDate >= now && reminder.dueDate <= fiveDaysLater {
                    count += 1
                }
            }
        }
        return count
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
