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

    var noiseImage: UIImage
    @Published var text: String?
    @Published var backgroundColor: Color

    init(id: String, page_index: String, position: (x: Int, y: Int), text: String? = nil, backgroundColor: Color, noiseImage: UIImage) {
        self.id = id
        self.page_index = page_index
        self.position = position
        self.text = text
        self.backgroundColor = backgroundColor
        self.noiseImage = noiseImage
    }

    static func == (lhs: Block, rhs: Block) -> Bool {
          return lhs.id == rhs.id &&
                 lhs.page_index == rhs.page_index &&
                 lhs.position == rhs.position &&
                 lhs.backgroundColor == rhs.backgroundColor &&
                 lhs.noiseImage == rhs.noiseImage &&
                 lhs.text == rhs.text
      }
    
    var description: String {
        return "Block(id: \(id), position: (\(position.x), \(position.y)), text: \(text ?? "nil"), isFlashing: \(isFlashing), backgroundColor: \(backgroundColor))"
    }
}
