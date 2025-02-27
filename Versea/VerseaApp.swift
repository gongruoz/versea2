//
//  VerseaApp.swift
//  Versea
//
//  Created by Hazel Gong on 2024/9/15.
//
//
import SwiftUI
import UIKit

@main
struct VerseaApp: App {
     @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    static let shared = WordManager()
    
    var body: some Scene {
        WindowGroup {
            IntroView()
        }
    }
}
