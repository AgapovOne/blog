//
//  SystemViewModel.swift
//  fcistalk
//
//  Created by Alex Agapov on 22.06.2023.
//

import Foundation

@MainActor
final class FcisSystemViewModel: ObservableObject {

    enum State: Hashable {
        case initial
        case loading
        case loaded(String)
    }

    enum Event: Hashable {
        enum ViewEvent: Hashable {
            case didTapButton
            case didAppear
        }

        enum ViewModelEvent: Hashable {
            case finishLoading(Fact)
            case failedLoading(String)
        }

        case view(ViewEvent)
        case model(ViewModelEvent)
    }

    enum Decision: Hashable {
        case load
        case track(Event)
        case log(String)
        case showSnackbar(String)
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

    func handle(_ event: Event.ViewEvent) {
        handle(.view(event))
    }

    private func handle(_ event: Event) {
        let decisions = Self.makeDecisions(event, &state)
        decisions.forEach {
            switch $0 {
                case .load:
                    Task {
                        do {
                            let fact = try await deps.fetchFact()
                            handle(.model(.finishLoading(fact)))
                        } catch {
                            handle(.model(.failedLoading(error.localizedDescription)))
                        }
                    }
                case .log(let something):
                    deps.log(something)
                case .track(let event):
                    deps.track(event)
                case .showSnackbar(let message):
                    deps.showSnackbar(message)
            }
        }
    }

    static func makeDecisions(
        _ event: Event,
        _ state: inout State
    ) -> [Decision] {
        switch event {
            case .view(.didTapButton):
                state = .loading
                return [.track(event), .load]
            case .view(.didAppear):
                return []
            case .model(.failedLoading(let error)):
                return [.log(error), .showSnackbar("SHTO-TO POSHLO NE TAQ")]
            case .model(.finishLoading(let fact)):

                state = .loaded(fact.text)
                return [.log(fact.text)]
        }
    }
}
