//
//  fcistalkTests.swift
//  fcistalkTests
//
//  Created by Alex Agapov on 21.06.2023.
//

import XCTest
@testable import fcistalk

final class FcisSystemViewModelTests: XCTestCase {

    func test_effects_onUserTap_startsLoading() async throws {
        var state = FcisSystemViewModel.State.initial
        let effects = FcisSystemViewModel.makeEffects(.view(.userDidTapButton), &state)

        // Isolated match only on one function of our system
        XCTAssertEqual(state, .loading)
        XCTAssertTrue(effects.contains(.load))
    }

    func test_effects_onFinishLoading_setsFact() async throws {
        var state = FcisSystemViewModel.State.loading
        let effects = FcisSystemViewModel.makeEffects(.system(.finishLoading(.init(text: "some fact"))), &state)

        // Complete match
        XCTAssertEqual(state, .loaded("some fact"))
        XCTAssertEqual(effects, [.log("some fact")])
    }
}
