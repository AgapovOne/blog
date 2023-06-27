//: [Previous](@previous)

import Foundation

var globalState = 0

func userDidTapButton(
    showSnackbar: () -> Void
) {
    globalState += 1
    showSnackbar()
}

print(globalState)
userDidTapButton {
    print("Big snackbar")
}
print(globalState)

//: [Next](@next)
