import Foundation

let endpoint = URL(string: "https://uselessfacts.jsph.pl/api/v2/facts/random?language=ru")!

public func call() async throws -> Data {
    try await URLSession.shared.data(
        for: URLRequest(url: endpoint)
    ).0
}

public struct Fact: Decodable {
    public let text: String
}
