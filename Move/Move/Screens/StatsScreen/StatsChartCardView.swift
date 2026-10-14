//
//  StatsChartCardView.swift
//  Move
//
//  Created by Tomáš Dyntar on 15.06.2026.
//

import SwiftUI
import Charts

struct StatsChartCardView: View {
    let dailyVisits: [DailyVisit]

    private var hasVisits: Bool {
        dailyVisits.contains { $0.count > 0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Visits last 30 days")
                .font(.title3.bold())
                .padding(.horizontal, 12)
                .padding(.top, 12)

            if hasVisits {
                Chart(dailyVisits) { day in
                    BarMark(
                        x: .value("Day", day.date, unit: .day),
                        y: .value("Visits", day.count)
                    )
                    .foregroundStyle(Color.accentColor)
                }
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 6)) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.day().month())
                    }
                }
                .frame(height: 180)
                .padding()
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("No visited places yet")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("Places you visit will appear here")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 180)
                .padding()
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemGray6))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}
