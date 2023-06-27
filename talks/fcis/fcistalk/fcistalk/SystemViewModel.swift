//
//  SystemViewModel.swift
//  fcistalk
//
//  Created by Alex Agapov on 22.06.2023.
//

import Foundation

enum Event {
    case userDidTapButton
}

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
        let call: () async throws -> Data
    }

    let deps: Deps

    init(
        deps: Deps
    ) {
        self.deps = deps
    }

    func handle(_ event: Event) {
        state = .loading
        deps.track(event)
        Task {
            do {
                let data = try await deps.call()
                deps.log(String(data: data, encoding: .utf8)!)
                let fact = try JSONDecoder().decode(Fact.self, from: data)
                deps.log(fact)
                state = .loaded(fact.text)
            } catch {
                deps.log(error)
                deps.showSnackbar("SHTO-TO POSHLO NE TAQ")
            }
        }
    }
}
