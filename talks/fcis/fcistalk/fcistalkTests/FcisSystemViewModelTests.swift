//
//  fcistalkTests.swift
//  fcistalkTests
//
//  Created by Alex Agapov on 21.06.2023.
//

import XCTest
@testable import fcistalk

@MainActor
final class FcisSystemViewModelTests: XCTestCase {

    func test_effects_onUserTap_startsLoading() async throws {
        var state = FcisSystemViewModel.State.initial
        let decisions = FcisSystemViewModel.makeDecisions(.view(.didTapButton), &state)

        // Isolated match only on one function of our system
        XCTAssertEqual(state, .loading)
        XCTAssertTrue(decisions.contains(.load))
    }

    func test_effects_onFinishLoading_setsFact() async throws {
        var state = FcisSystemViewModel.State.loading
        let decisions = FcisSystemViewModel.makeDecisions(
            .model(.finishLoading(.init(text: "some fact"))),
            &state
        )

        // Complete match
        XCTAssertEqual(state, .loaded("some fact"))
        XCTAssertEqual(decisions, [.log("some fact")])
    }
}
