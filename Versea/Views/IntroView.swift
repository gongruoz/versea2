import SwiftUI

struct IntroView: View {
    @State private var isIntroComplete = false
    @State private var introOpacity = 0.0
    @State private var showCanvas = false
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            if showCanvas {
                // Main app content with fade-in effect
                CanvasView()
                    .transition(.opacity)
                    .animation(.easeIn(duration: 1.0), value: showCanvas) // Fade-in animation
            } else {
                // Intro screen with logo, name, and slogan
                VStack(spacing: 0) { // Control spacing between elements
                    Spacer()
                    
                    // App name with custom position
                    Text("Lumino")
                        .font(.custom("IM FELL DW Pica", size: 30))
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.top, 20) // Padding above the text
                        .offset(y: -20) // Fine-tune position using offset

                    // Logo with custom frame and position
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.6), Color.white.opacity(0)]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 60
                            )
                        )
                        .padding(5)
                        .blur(radius: 10)
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .offset(y: -10) // Fine-tune position using offset

                    // Slogan with custom position and padding
                    Text("a world of many worlds \n a poem of many poems")
                        .font(.custom("IM FELL DW Pica", size: 20))
                        .multilineTextAlignment(.center)
                        .padding(.top, 10) // Padding above the slogan text
                        .padding(.horizontal, 40) // Add horizontal padding for alignment
                        .offset(y: 20) // Fine-tune position using offset

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensures full width and height
                .background(Color.black) // Background color for full screen
                .foregroundColor(.white) // Text color, adjust as needed
                .opacity(introOpacity) // Set initial opacity
                .ignoresSafeArea() // Ensures no padding from safe area
                .onAppear {
                    // Fade-in effect on appear
                    withAnimation(.easeIn(duration: 1.0)) {
                        introOpacity = 1.0
                    }
                    
                    // Timer to fade out and transition after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation(.easeOut(duration: 1.0)) {
                            introOpacity = 0.0
                        }
                        // Delay to allow fade-out before transitioning
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            showCanvas = true
                        }
                    }
                }
            }
        }
    }
}



struct ContentView: View {
    var body: some View {
        IntroView()
    }
}

