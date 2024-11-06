//
//  Screenshot.swift
//  Versea
//
//  Created by Hazel Gong on 2024/11/3.
//

import SwiftUI

struct Screenshot: View {
    var points: [[Point]] // 接收外部传入的点数组  上半部分
    var wordsArr: [String] // 接收外部传入的单词数组 下半部分
    
    @State private var image: UIImage?
    
    
    var body: some View {
        VStack() {
            HStack(spacing: 3) { // 设置 HStack 的间距为 3
                ForEach(0..<4) { _ in // 生成 5 个 PointsView
                    PointsView(points: generateRandomPoints()) // 调用生成随机点的函数，或替换为外部传入的 points
                        .frame(width: (UIScreen.main.bounds.width / 5), height: 100) // 设置宽度为屏幕宽度的 1/5
                }
            }
            
            VStack(spacing: 10) { // 使用 VStack 垂直排列 WorldsView
                ForEach(0..<4, id: \.self) { _ in
                    //  替换成wordPoints
                    WorldsView(points: generateWordRandomPoints(wordsArr: self.wordsArr)) // 生成多个 WorldsView ，
                        .frame(height: 150) // 设置每个 WorldsView 的高度
                        .background(Color.white) // 背景颜色
                        .cornerRadius(10) // 圆角效果
                        .shadow(radius: 5) // 添加阴影
                }
            }
            .padding() // 添加内边距
            .background(Color.gray.opacity(0.1)) // 整个背景颜色
        }
        
        // 按钮用于截图
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

        // 保存到相册   NSPhotoLibraryAddUsageDescription
        UIImageWriteToSavedPhotosAlbum(screenshot, nil, nil, nil)
        
    }
    
}






