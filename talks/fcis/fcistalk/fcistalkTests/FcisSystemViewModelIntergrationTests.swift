//
//  FcisSystemViewModelIntergrationTests.swift
//  fcistalkTests
//
//  Created by Alex Agapov on 22.06.2023.
//

import XCTest
@testable import fcistalk

final class FcisSystemViewModelIntegrationTests: XCTestCase {

    func testExample() async throws {

        let expectation = expectation(description: "joke loading")

        let viewModel = FcisSystemViewModel(
            deps: .init(
                track: { _ in },
                showSnackbar: { _ in},
                log: { _ in },
                call: {
                    try await Task.sleep(for: .seconds(1))

                    defer {
                        expectation.fulfill()
                    }

                    let fact =  Fact(text: "some funny fact")
                    return try JSONEncoder().encode(fact)
                }
            )
        )

        viewModel.handle(.userDidTapButton)

        XCTAssertEqual(viewModel.state, .loading)

        wait(for: [expectation])

        try await Task.sleep(for: .seconds(1)) // WAT

        XCTAssertEqual(viewModel.state, .loaded("some funny fact"))
    }

}