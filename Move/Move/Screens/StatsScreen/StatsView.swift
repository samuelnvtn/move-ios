//
//  StatsView.swift
//  Move
//
//  Created by Tomáš Dyntar on 15.06.2026.
//

import SwiftUI

struct StatsView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = StatsViewModel()

    var body: some View {
            ScrollView {
                VStack(spacing: 20) {

                    StatsChartCardView(
                        dailyVisits: viewModel.state.dailyVisits
                    )

                    StatsBadgesGridView(
                        badges: viewModel.state.badges
                    )

                    StatsAchievementsView(
                        achievements: viewModel.state.achievements
                    )
                }
                .padding(16)
            }
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.large)
            .toolbar(.hidden, for: .tabBar)
            .onAppear {
                viewModel.loadStats()
            }
        
    }
}

#Preview {
    StatsView()
}
