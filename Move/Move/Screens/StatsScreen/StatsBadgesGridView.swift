//
//  StatsBadgesGridView.swift
//  Move
//
//  Created by Tomáš Dyntar on 15.06.2026.
//

import SwiftUI

struct StatsBadgesGridView: View {

    let badges: [StatsBadge]

    private let columns = Array(
        repeating: GridItem(.flexible()),
        count: 5
    )

    var body: some View {

        VStack(alignment: .leading, spacing: 16) {

            Text("Badges")
                .font(.title3.bold())

            LazyVGrid(
                columns: columns,
                spacing: 24
            ) {

                ForEach(badges.sorted(by: { $0.count > $1.count })) { badge in
                    BadgeView(badge: badge)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.systemGray6))
        )
    }
}

private struct BadgeView: View {

    let badge: StatsBadge

    var body: some View {

        VStack(spacing: 8) {

            Circle()
                .fill(badge.levelColor.opacity(0.25))
                .frame(width: 44, height: 44)
                .overlay {

                    Image(systemName: badge.icon)
                        .font(.system(size: 18))
                        .foregroundStyle(badge.levelColor)
                }

            Text(badge.title)
                .font(.caption2)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Text(progressText)
                .font(.caption2.monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }

    private var progressText: String {

        let levels = [1, 5, 15, 40, 100, 500]

        guard let next = levels.first(where: {
            badge.count < $0
        }) else {
            return "500+"
        }

        return "\(badge.count)/\(next)"
    }
}
