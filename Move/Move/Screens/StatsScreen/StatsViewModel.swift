//
//  StatsViewModel.swift
//  Move
//
//  Created by Tomáš Dyntar on 15.06.2026.
//

import Foundation
import Observation

@Observable
final class StatsViewModel {

    var state = StatsViewState()

    private let dataManager: DataManaging

    init() {
        self.dataManager = DIContainer.shared.resolve()
    }

    func loadStats() {
        let places = dataManager.fetchPlaces()
        let tasks = dataManager.fetchTasks()

        let visitedPlaces = places.filter { $0.visited }
        let completedTasks = tasks.filter { $0.isCompleted }

        state.dailyVisits = makeDailyVisits(from: visitedPlaces)
        state.badges = makeBadges(from: visitedPlaces)

        state.achievements = [
            AchievementItem(
                title: "Visited Places",
                icon: "mappin.and.ellipse",
                value: visitedPlaces.count
            ),
            AchievementItem(
                title: "Completed Tasks",
                icon: "checkmark.circle.fill",
                value: completedTasks.count
            )
        ]
    }

    private func makeBadges(from places: [Place]) -> [StatsBadge] {
        PlaceType.allCases.map { type in
            StatsBadge(
                title: type.statsName,
                icon: type.sfSymbol,
                count: places.filter { $0.type == type }.count
            )
        }
    }

    private func makeDailyVisits(from places: [Place]) -> [DailyVisit] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var visits: [DailyVisit] = []

        for offset in (0..<30).reversed() {
            guard let date = calendar.date(
                byAdding: .day,
                value: -offset,
                to: today
            ) else { continue }

            let count = places.filter { place in
                guard let visitedOn = place.visitedOn else { return false }
                return calendar.isDate(visitedOn, inSameDayAs: date)
            }.count

            visits.append(DailyVisit(date: date, count: count))
        }

        return visits
    }
}
