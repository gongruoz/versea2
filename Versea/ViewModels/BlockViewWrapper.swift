//
//  BlockViewWrapper.swift
//  Versea
//
//  Created by Hazel Gong on 2024/11/5.
//

import SwiftUI

struct BlockViewWrapper: View {
    @State private var isVisible = false
    let word: String
    let block: Block
    let delay: Double

    var body: some View {
        Group {
            if isVisible {
                BlockView(word: .constant(word), block: block)
            } else {
                // Debug 用的占位符
                Color.clear.frame(width: 50, height: 50)
            }
        }
        .onAppear {
            Task {
                let nanosecondsDelay = UInt64(delay * 1_000_000_000)
                print("Starting delay of \(delay) seconds for \(word)") // Debug 信息
                try? await Task.sleep(nanoseconds: nanosecondsDelay)
                withAnimation {
                    isVisible = true
                    print("BlockView for '\(word)' is now visible") // Debug 信息
                }
            }
        }
    }
}
