//
//  FcisSystemViewModelIntergrationTests.swift
//  fcistalkTests
//
//  Created by Alex Agapov on 22.06.2023.
//

import XCTest
@testable import fcistalk

@MainActor
final class FcisSystemViewModelIntegrationTests: XCTestCase {

    func testExample() async throws {

        let expectation = expectation(description: "joke loading")

        let viewModel = FcisSystemViewModel(
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

        viewModel.handle(.didTapButton)

        XCTAssertEqual(viewModel.state, .loading)

        wait(for: [expectation])

        XCTAssertEqual(viewModel.state, .loaded("some funny fact"))
    }

}
