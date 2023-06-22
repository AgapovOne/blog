//
//  SystemViewModel.swift
//  fcistalk
//
//  Created by Alex Agapov on 22.06.2023.
//

import Foundation

final class FcisSystemViewModel: ObservableObject {

    enum State: Hashable {
        case initial
        case loading
        case loaded(String)
    }

    enum Event: Hashable {
        enum ViewEvent: Hashable {
            case userDidTapButton
        }

        enum SystemEvent: Hashable {
            case finishLoading(Fact)
            case failedLoading(String)
        }

        case view(ViewEvent)
        case system(SystemEvent)
    }

    enum Effect: Hashable {
        case load
        case track(Event)
        case log(String)
        case showSnackbar(String)
    }

    @Published var state: State = .initial

    // Dependencies
    let track: (Event) -> Void
    let showSnackbar: (String) -> Void
    let log: (Any...) -> ()
    let call: () async throws -> Data

    init(
        track: @escaping (Event) -> Void,
        showSnackbar: @escaping (String) -> Void,
        log: @escaping (Any...) -> (),
        call: @escaping () async throws -> Data
    ) {
        self.track = track
        self.showSnackbar = showSnackbar
        self.log = log
        self.call = call
    }

    func handle(_ event: Event.ViewEvent) {
        handle(.view(event))
    }

    private func handle(_ event: Event) {
        Self.makeEffects(event, &state).forEach {
            switch $0 {
                case .load:
                    Task {
                        do {
                            let data = try await call()
                            let fact = try JSONDecoder().decode(Fact.self, from: data)
                            handle(.system(.finishLoading(fact)))
                        } catch {
                            handle(.system(.failedLoading(error.localizedDescription)))
                        }
                    }
                case .log(let something):
                    log(something)
                case .track(let event):
                    track(event)
                case .showSnackbar(let message):
                    showSnackbar(message)
            }
        }
    }


    static func makeEffects(
        _ event: Event,
        _ state: inout State
    ) -> [Effect] {
        switch event {
            case .view(.userDidTapButton):
                state = .loading
                return [.track(event), .load]
            case .system(.failedLoading(let error)):
                return [.log(error), .showSnackbar("SHTO-TO POSHLO NE TAQ")]
            case .system(.finishLoading(let fact)):

                state = .loaded(fact.text)
                return [.log(fact.text)]
        }
    }
}
