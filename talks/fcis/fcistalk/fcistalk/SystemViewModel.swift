//
//  SystemViewModel.swift
//  fcistalk
//
//  Created by Alex Agapov on 22.06.2023.
//

import Foundation
import SwiftUI

enum Event {
    case userDidTapButton
    case onAppear
}

@MainActor
final class SystemViewModel: ObservableObject {

    enum State: Equatable {
        case initial
        case loading
        case loaded(String)
    }

    @Published var state: State = .initial

    struct Deps {
        let track: (Event) -> Void
        let showSnackbar: (String) -> Void
        let log: (Any...) -> ()
        let fetchFact: () async throws -> Fact
    }

    let deps: Deps

    init(
        deps: Deps
    ) {
        self.deps = deps
    }

    func handle(_ event: Event) {
        deps.log(event)
        switch event {
            case .userDidTapButton:
                state = .loading
                deps.track(event)
                Task {
                    do {
                        let fact = try await deps.fetchFact()
                        deps.log(fact)
                        state = .loaded(fact.text)
                    } catch {
                        deps.log(error)
                        deps.showSnackbar("SHTO-TO POSHLO NE TAQ")
                    }
                }
            case .onAppear:
                break
        }
    }
}
