//
//  fcistalkApp.swift
//  fcistalk
//
//  Created by Alex Agapov on 21.06.2023.
//

import SwiftUI

@main
struct fcistalkApp: App {

    @StateObject var viewModel = SystemViewModel(
        deps: .init(
            track: { _ in },
            showSnackbar: { _ in },
            log: { print($0) },
            fetchFact: {
                let data = try await Facts.get()
                return try JSONDecoder().decode(Fact.self, from: data)
            }
        )
    )

    var body: some Scene {
        WindowGroup {
            ContentView(
                viewModel: viewModel
            )
        }
    }
}
