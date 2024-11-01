//
//  BlockView.swift
//  Versea
//
//  Created by Hazel Gong on 2024/9/15.

// add onTap

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

// 单个方块的视图，包括文字显示和背景效果
struct BlockView: View {
    @Binding var word: String
    var onChange: ((String, Color) -> Void)?
    @ObservedObject var block: Block // 传入当前 Block 对象
    @State private var isVisible = false // control opacity of shimmer behind flashing texts
    @State private var isTextVisible = false // State variable to control opacity of text
    @State private var animationDuration: Double = Double.random(in: 1.8...2.2)



    var body: some View {
        ZStack {

            
            // optional inner shadow
//            if !block.isFlashing {
//                RoundedRectangle(cornerRadius: 25, style: .continuous)
//                .fill(
//                    .shadow(.inner(color: Color(red: 197/255, green: 197/255, blue: 197/255),radius: 3, x:3, y: 3))
//                    .shadow(.inner(color: .white, radius: 3, x: -3, y: -3))
//                ).opacity(0.6)
//                    .padding(3)
//                    .blur(radius: 8)
//                
//            }
            
            // if the block is tapped and kept on the screen, there is an aura around the word
            if !block.isFlashing {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [Color.white.opacity(0.6), Color.white.opacity(0)]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .padding(3)
                    .blur(radius: 8)
            }
            
            // if the block is flashing, there is an animated flashing effect, but dimmer than the aura around the word
            
            if block.isFlashing && block.text != "" {
                
                
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [Color.white.opacity(0.6), Color.white.opacity(0)]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .animation(.easeInOut, value: 1)
                    .padding(3)
//                    .blur(radius: 8)
//                    .opacity(0.5)
                    .opacity(isVisible ? 0.5 : 0.1) // Animation target
                    .scaleEffect(isVisible ? 1.0 : 0.95) // Slight scaling effect to enhance the animation
                    .onAppear {
                        // Start an indefinite pulsing animation
                        withAnimation(.easeInOut(duration: animationDuration).repeatForever(autoreverses: true)) {
                            isVisible.toggle() // Toggle to change opacity and scale
                        }
                    }
                    
                
            }
            
            
            // Animate the text opacity and scale
            Text(word)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .font(.custom("Courier", size: 20))
                .padding(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2))
                .opacity(isTextVisible ? 0.4 : 0.8) // Tie to the state variable
                .onAppear {
                    // Trigger the animation when the view appears
                    withAnimation(.easeIn(duration: animationDuration).repeatForever(autoreverses: true)) {
                        isTextVisible.toggle()
                    }
                }
        
        }
        .clipped()
        .onTapGesture {
            if block.text != "" {
                block.isFlashing = !block.isFlashing
            }
        }
    }
}
