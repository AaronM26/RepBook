import Foundation
import SwiftUI

let exampleGraphData = GraphData(points: [45, 25, 18, 22, 30, 15, 68, 14, 23])

struct GraphData {
    var points: [CGFloat] // Raw data points
    
    var horizontalPadding: CGFloat {
        return (points.max() ?? 0 - (points.min() ?? 0)) * 0.1 // 10% padding
    }

    func normalizedPoint(index: Int, frame: CGRect) -> CGPoint {
        let xPosition = (frame.width - horizontalPadding * 2) * CGFloat(index) / CGFloat(points.count - 1) + horizontalPadding
        let yPosition = (1 - (points[index] - minValue) / (maxValue - minValue)) * (frame.height - horizontalPadding * 2) + horizontalPadding
        return CGPoint(x: xPosition, y: yPosition)
    }
    
    // Calculate the padding only once to avoid recursion
       private var padding: CGFloat {
           let range = points.max() ?? 0 - (points.min() ?? 0)
           return range * 0.1 // 10% padding
       }
       
       var maxValue: CGFloat {
           return (points.max() ?? 0) + padding
       }
       
       var minValue: CGFloat {
           return (points.min() ?? 0) - padding
       }
    var peakIndex: Int? { points.indices.max(by: { points[$0] < points[$1] }) }
    var valleyIndex: Int? { points.indices.min(by: { points[$0] < points[$1] }) }
}

struct LabelView: View {
    var text: String
    var position: CGPoint
    var colorScheme: (dark: Color, med: Color, light: Color)
    
    var body: some View {
        Text(text)
            .font(.system(size: 14))
            .fontWeight(.medium)
            .padding(5)
            .background(colorScheme.light)
            .foregroundColor(colorScheme.dark)
            .cornerRadius(5)
            .position(position)
    }
}


struct CustomGraphCardView: View {
    var titleNumberPairs: [(title: String, number: Int)]
    var currentColorScheme: (dark: Color, med: Color, light: Color)

    var body: some View {
        HStack {
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
            .padding(.vertical)

            // Right side (Graph)
            VStack {
                // Inside CustomGraphCardView
                LineGraph(data: exampleGraphData, colorScheme: currentColorScheme)

                                .frame(maxWidth: .infinity) // Maximize the width available
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.63) // Set width for the graph area
            .aspectRatio(1, contentMode: .fit) // Attempt to maintain a square aspect ratio
            .padding(.vertical) // Adds vertical spacing
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

struct LineGraph: View {
    var data: GraphData
    var colorScheme: (dark: Color, med: Color, light: Color)
    @State private var graphProgress: CGFloat = 0

    var body: some View {
        ZStack {
            // Graph Line
            GeometryReader { geometry in
                Path { path in
                    let firstPoint = data.normalizedPoint(index: 0, frame: geometry.frame(in: .local))
                    path.move(to: firstPoint)
                    for index in data.points.indices {
                        let nextPoint = data.normalizedPoint(index: index, frame: geometry.frame(in: .local))
                        path.addLine(to: nextPoint)
                    }
                }
                .trim(from: 0, to: graphProgress) // Only draw part of the line based on progress
                .stroke(colorScheme.light, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1)) {
                    graphProgress = 1 // Animate the line drawing
                }
            }

            GraphPoints(data: data, colorScheme: colorScheme, graphProgress: graphProgress)
        }
        .clipped()
        .padding(.all, 15)
    }
}

struct GraphPoints: View {
    var data: GraphData
    var colorScheme: (dark: Color, med: Color, light: Color)
    var graphProgress: CGFloat

    var body: some View {
        GeometryReader { geometry in
            ForEach(data.points.indices, id: \.self) { index in
                if CGFloat(index) / CGFloat(data.points.count - 1) <= graphProgress {
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(colorScheme.dark)
                        .position(data.normalizedPoint(index: index, frame: geometry.frame(in: .local)))
                }
            }

            // Labels for peak and valley points
            if let peakIndex = data.peakIndex, CGFloat(peakIndex) / CGFloat(data.points.count - 1) <= graphProgress {
                LabelView(
                    text: "\(data.points[peakIndex])",
                    position: adjustedLabelPosition(index: peakIndex, frame: geometry.frame(in: .local), geometry: geometry),
                    colorScheme: colorScheme
                )
                .zIndex(1) // Ensure labels are on top
            }
            
            if let valleyIndex = data.valleyIndex, CGFloat(valleyIndex) / CGFloat(data.points.count - 1) <= graphProgress {
                LabelView(
                    text: "\(data.points[valleyIndex])",
                    position: adjustedLabelPosition(index: valleyIndex, frame: geometry.frame(in: .local), geometry: geometry),
                    colorScheme: colorScheme
                )
                .zIndex(1) // Ensure labels are on top
            }
        }
    }

    private func adjustedLabelPosition(index: Int, frame: CGRect, geometry: GeometryProxy) -> CGPoint {
        var position = data.normalizedPoint(index: index, frame: frame)
        // Adjust label position if it's near the edges
        if position.x < 20 { position.x = 30 }
        if position.x > geometry.size.width - 30 { position.x = geometry.size.width - 30 }
        return position
    }
}
