//
//  VIbeSwiftUIApp.swift
//  VIbeSwiftUI
//
//  Created by Oren Idan on 01/06/2025.
//

import SwiftUI
import ComposableArchitecture

@main
struct VIbeSwiftUIApp: App {
    // Initialize the main store for the application
    // If you had a higher-level AppFeature, this would be StoreOf<AppFeature>
    // For now, ChartMakerFeature is the root.
    static let store = Store(initialState: ChartMakerFeature.State()) {
        ChartMakerFeature()
            ._printChanges() // Optional: for debugging state changes
    }

    var body: some Scene {
        WindowGroup {
            ChartMakerView(store: VIbeSwiftUIApp.store)
        }
    }
}
