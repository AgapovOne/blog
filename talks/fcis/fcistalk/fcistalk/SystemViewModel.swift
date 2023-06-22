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

    func handle(_ event: Event) {
        state = .loading
        track(event)
        Task {
            do {
                let data = try await call()
                log(String(data: data, encoding: .utf8)!)
                let fact = try JSONDecoder().decode(Fact.self, from: data)
                log(fact)
                state = .loaded(fact.text)
            } catch {
                log(error)
                showSnackbar("SHTO-TO POSHLO NE TAQ")
            }
        }
    }
}
