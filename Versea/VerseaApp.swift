//
//  VerseaApp.swift
//  Versea
//
//  Created by Hazel Gong on 2024/9/15.
//
//
import SwiftUI

@main
struct VerseaApp: App {
    
    init() {
        // 在应用启动时异步加载词库
        Task {
            await WordManager.shared.generateWordBank(from: "Generate a poetic line about stars.")
            print("词库加载完成")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            CanvasView()
        }
    }
}
