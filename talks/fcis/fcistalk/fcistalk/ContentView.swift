//
//  ContentView.swift
//  fcistalk
//
//  Created by Alex Agapov on 21.06.2023.
//

import SwiftUI

struct ContentView: View {

    let viewModel: SystemViewModel

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {

        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            viewModel: .init(
                track: { print("track", $0) },
                showSnackbar: { print("snackbar", $0) },
                log: { print($0) },
                call: { Data() }
            )
        )
    }
}
