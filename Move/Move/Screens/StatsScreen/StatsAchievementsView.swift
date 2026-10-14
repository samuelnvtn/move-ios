//
//  StatsAchievementsView.swift
//  Move
//
//  Created by Tomáš Dyntar on 15.06.2026.
//

import SwiftUI

struct StatsAchievementsView: View {

    let achievements: [AchievementItem]

    var body: some View {

        VStack(alignment: .leading, spacing: 16) {

            Text("Counters")
                .font(.title3.bold())

            ForEach(achievements) { item in

                HStack {

                    Image(systemName: item.icon)
                        .font(.title2)

                    Text(item.title)

                    Spacer()

                    Text(format(item.value))
                        .font(.title3.bold())
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.systemGray6))
        )
    }

    private func format(_ value: Int) -> String {

        if value >= 1_000_000 {
            return "\(value / 1_000_000)M"
        }

        if value >= 1_000 {
            return "\(value / 1_000)k"
        }

        return "\(value)"
    }
}
