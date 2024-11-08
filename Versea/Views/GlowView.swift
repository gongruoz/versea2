//
//  GlowView.swift
//  Versea
//
//  Created by Hazel Gong on 2024/11/9.
//

import SwiftUI

struct GlowView: View {
    @Binding var isVisible: Bool  // 控制白光显示/隐藏的绑定变量
    @State private var scale: CGFloat = 0.5  // 白光初始大小为原始尺寸的 50%
    
    var body: some View {
        RoundedRectangle(cornerRadius: 300, style: .continuous)  // 圆角矩形，圆角半径为 30
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.9),  // 中心点白光不透明度为 60%
                        Color.white.opacity(0)      // 边缘完全透明
                    ]),
                    center: .center,  // 渐变中心点
                    startRadius: 0,   // 从中心点开始
                    endRadius: 60     // 渐变扩散半径
                )
            )
            .padding(5)  // 四周留出 5 点空隙
            .blur(radius: 10)  // 模糊效果，让白光更柔和
            .scaledToFit()     // 保持宽高比
            .frame(width: 2000, height: 2000)  // 白光整体尺寸
            .scaleEffect(scale)  // 缩放效果，由 scale 状态控制
            .opacity(isVisible ? 1 : 0)  // 显示/隐藏控制
            .onChange(of: isVisible) { newValue in  // 监听显示状态变化
                if newValue {  // 当显示时
                    withAnimation(.easeIn(duration: 1.5)) {  // 0.5秒淡入动画
                        scale = 2.0  // 放大到原始尺寸的 2 倍
                    }
                } else {  // 当隐藏时
                    scale = 0.5  // 重置为初始大小
                }
            }
    }
}
