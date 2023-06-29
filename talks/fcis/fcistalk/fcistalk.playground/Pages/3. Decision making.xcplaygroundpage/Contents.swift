//: [Previous](@previous)

import Foundation

// func makeDecision(input: T) -> Decision
// func decisions(input: T) -> [Decision]

//

enum Decision {
    case showSnackbar
}

enum State {
    case loading
    case failed
}

func userDidTapButton(state: State) -> Decision? {
    switch state {
        case .failed: return .showSnackbar
        case .loading: return nil
    }
}

userDidTapButton(state: .failed)
userDidTapButton(state: .loading)

//: [Next](@next)
