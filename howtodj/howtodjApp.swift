//
//  howtodjApp.swift
//  howtodj
//
//  Created by Paul Crews on 10/13/23.
//

import SwiftUI
import SwiftData

@main
struct howtodjApp: App {

    let model_container: ModelContainer
    
    init() {
        do {
            model_container = try ModelContainer(for: Song.self)
        } catch {
            fatalError("Could not initialize ModelContainer")
        }
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(model_container)
    }
}
