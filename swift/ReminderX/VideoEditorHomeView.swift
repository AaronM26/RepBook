import SwiftUI
import UIKit

struct VideoEditorHomeView: View {
    @State private var showActionSheet = false
    @State private var gradientRotation: Double = 0
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
            
            VStack {
                // White Rounded Rectangle containing the content
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.white)
                    .shadow(color: .gray.opacity(0.2), radius: 10, x: -5, y: -5)
                    .shadow(color: .gray.opacity(0.2), radius: 10, x: 5, y: 5)
                    .padding(.horizontal, 20) // Adding horizontal padding
                    .padding(.bottom, 68)
                    VStack(spacing: 20) {
                            HStack {
                                Text("Video Editor")
                                    .font(.largeTitle)
                                    .bold()
                                    .padding(.leading, 20)
                                
                                Spacer()
                                
                                Button(action: {
                                    showActionSheet.toggle()
                                }) {
                                    Image(systemName: "plus")
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                        .foregroundColor(Color.gray)
                                        .padding(EdgeInsets(top: 10, leading: 5, bottom: 5, trailing: 25))
                                }
                            }
                        }
                        .padding()
                Spacer()
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .onAppear {
            withAnimation(Animation.linear(duration: 8).repeatForever(autoreverses: false)) {
                gradientRotation = 360
            }
        }
    }
}

