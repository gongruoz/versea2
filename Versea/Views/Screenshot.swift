import SwiftUI

struct Screenshot: View {
    var points: [[Point]] // Array of arrays for the top section
    var wordsArr: [[String]] // Array of arrays for the bottom section
    
    @State private var image: UIImage?
    
    var body: some View {
        VStack {
            // Display each set of points as a separate PointsView
            HStack(spacing: 3) {
                ForEach(points, id: \.self) { pointSet in
                    PointsView(points: pointSet) // Pass each set of points to PointsView
                        .frame(width: UIScreen.main.bounds.width / 5, height: 100)
                }
            }
            
            // Display each set of words as a separate WorldsView
            VStack(spacing: 10) {
                ForEach(wordsArr, id: \.self) { wordArray in
                    WorldsView(points: createWorldPoints(from: wordArray)) // Create WorldPoints for each set of words
                        .frame(height: 150)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
        }
        
        // Button to capture screenshot
        Button(action: {
            self.captureScreenshot()
        }) {
            Text("Save to Photos")
        }
    }
    
    func captureScreenshot() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        let screenshot = renderer.image { context in
            UIApplication.shared.windows.first?.rootViewController?.view.drawHierarchy(in: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), afterScreenUpdates: true)
        }

        // Save to photo album (requires NSPhotoLibraryAddUsageDescription permission)
        UIImageWriteToSavedPhotosAlbum(screenshot, nil, nil, nil)
    }
    
    // Helper function to create WorldPoints for a given array of words
    func createWorldPoints(from words: [String]) -> [WorldPoint] {
        // Example layout for placing each word in a circle arrangement; modify as needed
        let radius: CGFloat = 60
        let centerX = UIScreen.main.bounds.width / 2
        let centerY: CGFloat = 75
        
        return words.enumerated().map { index, word in
            // Distribute words in a circle around the center
            let angle = CGFloat(index) * (.pi * 2 / CGFloat(words.count))
            let x = centerX + radius * cos(angle)
            let y = centerY + radius * sin(angle)
            return WorldPoint(x: x, y: y, text: word)
        }
    }
}
