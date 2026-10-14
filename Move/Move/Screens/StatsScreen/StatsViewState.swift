//
//  StatsViewState.swift
//  Move
//
//  Created by Tomáš Dyntar on 15.06.2026.
//

import Foundation

@Observable
final class StatsViewState {
    var dailyVisits: [DailyVisit] = []

    var badges: [StatsBadge] = []

    var achievements: [AchievementItem] = []
}
