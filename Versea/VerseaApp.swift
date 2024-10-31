//
//  VerseaApp.swift
//  Versea
//
//  Created by Hazel Gong on 2024/9/15.
//
//
import SwiftUI
import Foundation

@main
struct VerseaApp: App {
    static let shared = WordManager()
    init() {
        // 在应用启动时异步加载词库
        Task {
            let poemContent = RegionManager.shared.orderedPoem.flatMap { $0.1 }.joined(separator: " ")
            let prompt = poemContent.isEmpty ? "Generate a poetic line" : "Generate a poetic line about \(poemContent)"
            
            await WordManager.shared.generateWordBank(from: prompt)
            print("词库加载完成")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            CanvasView()
        }
    }
}
