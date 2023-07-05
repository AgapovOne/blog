//: [Previous](@previous)

import Foundation

struct Athlete {
    let trainingHours: Float
    let isInjured: Bool
}

enum Database {
    static func athletes() async -> [Athlete] {
        do {
            try await Task.sleep(for: .seconds(1))
            return [
                .init(trainingHours: 100, isInjured: true),
                .init(trainingHours: 1010, isInjured: false),
                .init(trainingHours: 10100, isInjured: true)
            ]
        } catch {
            return []
        }
    }
}

enum Aviasales {
    static func buyCheapTickets(_ athlete: Athlete) async {
        do {
            try await Task.sleep(for: .seconds(1))
            print("Bought ticket for \(athlete)")
        } catch {

        }
    }
}

func sendToOlympics() async {
    let athletes = await Database.athletes()
    for athlete in athletes {
        if athlete.trainingHours > 1000 && !athlete.isInjured {
            await Aviasales.buyCheapTickets(athlete)
        }
    }
}

await sendToOlympics()

/// ---



extension Aviasales {
    static func buyCheapTickets(_ athlete: PreparedAthlete) async {
        do {
            try await Task.sleep(for: .seconds(1))
            print("Bought ticket for \(athlete)")
        } catch {

        }
    }
}
func sendToOlympicsShell() async { // 🐚 Shell
    for athlete in filterPrepared(await Database.athletes()) {
        await Aviasales.buyCheapTickets(athlete)
    }
}

enum AthleteError: Error {
    case injured, untrained
}

struct PreparedAthlete {
    let trainingHours: Float
    let isInjured: Bool

    init(_ athlete: Athlete) throws {
        if athlete.isInjured { throw AthleteError.injured }
        if athlete.trainingHours < 1000 { throw AthleteError.untrained }
        self.trainingHours = athlete.trainingHours
        self.isInjured = athlete.isInjured
    }
}

func filterPrepared(_ athletes: [Athlete]) -> [PreparedAthlete] { // 🤯 Core
    athletes.compactMap { try? PreparedAthlete($0) }
}

await sendToOlympicsShell()

//: [Next](@next)
