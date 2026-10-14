//
//  StatsModels.swift
//  Move
//
//  Created by Tomáš Dyntar on 15.06.2026.
//

import Foundation
import SwiftUI

struct DailyVisit: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}

struct StatsBadge: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let count: Int
    
    var levelColor: Color {
        switch count {
        case 500...: return .blue
        case 100...: return .cyan
        case 40...:  return .yellow
        case 15...:  return .gray
        case 1...:   return .brown
        default:     return .secondary
        }
    }
}

struct AchievementItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let value: Int
}
