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

struct CustomTabBar: View {
    @Binding var selection: Int
    
    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            ForEach(0..<4) { index in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        selection = index
                    }
                }) {
                    ZStack {
                        // Image
                        Image(systemName: tabImageName(for: index))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: selection == index ? 32 : 24, height: selection == index ? 32 : 24)
                            .foregroundColor(selection == index ? .black.opacity(0.6) : .gray.opacity(0.5))
                    }
                }
                .frame(width: 60, height: 60)
                Spacer()
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
            return "chart.bar.xaxis"
        case 3:
            return "gear"
        default:
            return ""
        }
    }
}
