//
//  SmashtatsApp.swift
//  Smashtats
//
//  Created by Daniel Chung on 14/08/24.
//

import SwiftUI

@main
struct SmashtatsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
