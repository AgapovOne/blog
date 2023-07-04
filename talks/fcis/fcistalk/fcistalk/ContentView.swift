//
//  ContentView.swift
//  fcistalk
//
//  Created by Alex Agapov on 21.06.2023.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var viewModel: SystemViewModel

    var body: some View {
        VStack(spacing: 32) {
            Text("Tap a button to fetch new fact")
                .font(.largeTitle)
            switch viewModel.state {
                case .initial:
                    Text("Hello")
                case .loading:
                    Text("Loading")
                case let .loaded(fact):
                    HStack {
                        Image(systemName: "quote.bubble")
                        Text(fact)
                    }
            }
            Button(
                action: { viewModel.handle(.didTapButton) },
                label: { Label("New fact", systemImage: "network") }
            )
        }
        .padding()
        .onAppear {
            viewModel.handle(.didAppear)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            viewModel: .init(
                deps: .init(
                    track: { print("track", $0) },
                    showSnackbar: { print("snackbar", $0) },
                    log: { print($0) },
                    fetchFact: { Fact(text: "fake fact") }
                )
            )
        )
    }
}
