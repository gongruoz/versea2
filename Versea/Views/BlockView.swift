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
    @Binding var backgroundColor: Color
    var noiseImage: UIImage
    var onChange: ((String, Color) -> Void)?
    @ObservedObject var block: Block // 传入当前 Block 对象

    var body: some View {
        ZStack {
            Image(uiImage: noiseImage)
                .resizable()
                .scaledToFill()
                .opacity(1)
            backgroundColor
                .opacity(0.75).animation(.easeIn(duration: 1))
            
            // optional inner shadow
            if !block.isFlashing {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(
                    .shadow(.inner(color: Color(red: 197/255, green: 197/255, blue: 197/255),radius: 3, x:3, y: 3))
                    .shadow(.inner(color: .white, radius: 3, x: -3, y: -3))
                ).opacity(0.12)
                    .padding(3)
                    .blur(radius: 8)
                
            }
            
            withAnimation(.easeIn(duration: 1.5)) {
                Text(word)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .font(.custom("Pixelify Sans", size: 25))
                    .bold()
                    .padding(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2))
            }
        }
        .clipped()
        .onTapGesture {
//            let newWord = RegionManager.shared.generateRandomWord()
//            let newColor = Color.randomCustomColor()
//            onChange?(newWord, newColor)
            if block.text != "" {
                block.isFlashing = !block.isFlashing
            }
        }
    }
}
