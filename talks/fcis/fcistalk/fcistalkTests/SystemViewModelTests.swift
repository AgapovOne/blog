//
//  fcistalkTests.swift
//  fcistalkTests
//
//  Created by Alex Agapov on 21.06.2023.
//

import XCTest
@testable import fcistalk

final class SystemViewModelTests: XCTestCase {

    func testExample() async throws {

        let expectation = expectation(description: "joke loading")

        let viewModel = SystemViewModel(
            deps: .init(
                track: { _ in },
                showSnackbar: { _ in},
                log: { _ in },
                fetchFact: {
                    try await Task.sleep(for: .seconds(1))
                    defer {
                        expectation.fulfill()
                    }
                    return Fact(text: "some funny fact")
                }
            )
        )

        viewModel.handle(.userDidTapButton)

        XCTAssertEqual(viewModel.state, .loading)

        wait(for: [expectation])

        XCTAssertEqual(viewModel.state, .loaded("some funny fact"))
    }

}
