import Foundation

enum Facts {

    static let endpoint = URL(string: "https://uselessfacts.jsph.pl/api/v2/facts/random?language=ru")!

    public static func get() async throws -> Data {
        try await URLSession.shared.data(
            for: URLRequest(url: Facts.endpoint)
        ).0
    }
}

public struct Fact: Codable, Hashable {
    public let text: String
}
