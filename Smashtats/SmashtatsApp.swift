//
//  SmashtatsApp.swift
//  Smashtats
//
//  Created by Daniel Chung on 14/08/24.
//

import SwiftUI

@main
struct SmashtatsApp: App {
    @StateObject private var gameModel = GameModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameModel)
        }
    }
}