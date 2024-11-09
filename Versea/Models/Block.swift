//
//  Block.swift
//  Versea
//
//  Created by Hazel Gong on 2024/10/10.
//

import SwiftUI
import Foundation

struct BlockID: Hashable {
    let screenIndex: Int
    let blockIndex: Int
}


class Block: Identifiable, ObservableObject, Equatable {
    let id: String
    var page_index: String

    var position: (x: Int, y: Int)
    @Published var isFlashing: Bool = true // 点击之后会被设置成 false
    var index: Int = 0
    @Published var text: String?
    @Published var isExitButton = false // New property for exit button
    @Published var coordinateText: String?  // 添加坐标文本属性
    @Published var isSeedPhrase: Bool = false  // 标识是否为种子词

    
    init(id: String, page_index: String, position: (x: Int, y: Int), text: String? = nil) {
        self.id = id
        self.page_index = page_index
        self.position = position
        self.text = text
        self.coordinateText = nil
    }

    static func == (lhs: Block, rhs: Block) -> Bool {
          return lhs.id == rhs.id &&
                 lhs.page_index == rhs.page_index &&
                 lhs.position == rhs.position &&
//                 lhs.noiseImage == rhs.noiseImage &&
                 lhs.text == rhs.text
      }
    
    var description: String {
        return "Block(id: \(id), position: (\(position.x), \(position.y)), text: \(text ?? "nil"), isFlashing: \(isFlashing))"
    }
}
