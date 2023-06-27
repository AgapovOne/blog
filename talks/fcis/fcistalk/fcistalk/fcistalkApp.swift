//
//  fcistalkApp.swift
//  fcistalk
//
//  Created by Alex Agapov on 21.06.2023.
//

import SwiftUI

@main
struct fcistalkApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                viewModel: .init(
                    deps: .init(
                        track: { _ in },
                        showSnackbar: { _ in },
                        log: { _ in },
                        call: { Data() }
                    )
                )
            )
        }
    }
}
