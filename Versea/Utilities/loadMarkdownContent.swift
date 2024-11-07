//
//  loadMarkdownContent.swift
//  Versea
//
//  Created by Hazel Gong on 2024/11/8.
//

import Foundation
import SwiftUI

// 读取和解析 Markdown 文件内容
func loadMarkdownContent(from fileName: String) -> String? {
    guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: "md") else {
        print("找不到文件")
        return nil
    }
    do {
        return try String(contentsOf: fileURL, encoding: .utf8)
    } catch {
        print("读取文件出错：\(error)")
        return nil
    }
}

// poems = loadMarkdownContent(from: "poems") ?? "poems"
