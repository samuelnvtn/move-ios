//
//  HomeScreenView.swift
//  Move
//
//  Created by Samuel Novotný on 09.06.2026.
//

import SwiftUI

struct HomeView: View {

    @State private var viewModel = HomeViewModel()
    @State private var selectedAdditionalPlace: AdditionalPlace? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    UserLevelCard(user: viewModel.state.user)
                    achievementsSection
                    recommendedSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Dashboard")
            .sheet(item: $selectedAdditionalPlace) { additionalPlace in
                AdditionalPlaceDetailView(additionalPlace: additionalPlace, onUpdated: {
                    viewModel.loadAllData()
                })
            }
            .onAppear { viewModel.loadAllData() }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshAdditionalPlaces"))) { _ in
                viewModel.loadAllData()
            }
        }
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your badges")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                NavigationLink("View All") {
                    StatsView()
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.blue)
            }
            
            VStack(spacing: 12) {
                ForEach(viewModel.state.achievements) { badge in
                    HStack(spacing: 16) {
                        Circle()
                            .fill(badge.levelColor.opacity(0.15))
                            .frame(width: 44, height: 44)
                            .overlay {
                                Image(systemName: badge.icon)
                                    .font(.system(size: 18))
                                    .foregroundStyle(badge.levelColor)
                            }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(badge.title)
                                .font(.callout)
                                .fontWeight(.semibold)
                            Text("Visited \(badge.count) places")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 14))
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
    }

    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Recommended For You")
                .font(.headline)
                .fontWeight(.bold)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    if viewModel.state.recommendedPlaces.isEmpty {
                        ForEach(0..<2, id: \.self) { _ in
                            VStack(alignment: .leading, spacing: 0) {
                                Color(.systemGray5).frame(width: 160, height: 120)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Loading Place Name")
                                    Text("Category Name")
                                }
                                .padding(10)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .redacted(reason: .placeholder)
                        }
                    } else {
                        ForEach(viewModel.state.recommendedPlaces) { additionalPlace in
                            Button {
                                selectedAdditionalPlace = additionalPlace
                            } label: {
                                RecommendedCard(place: additionalPlace)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
}

private struct UserLevelCard: View {
    let user: User
    
    private let greenColor = Color(red: 52/255, green: 199/255, blue: 89/255)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 52, height: 52)
                    .overlay(
                        Image(systemName: "star.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.white)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("Current Level")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.85))
                    Text("Level \(user.level)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
                .padding(.leading, 8)

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Next Level")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.85))
                    Text("\(user.xpToNextLevel) XP")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.35))
                        .frame(height: 10)
                    Capsule()
                        .fill(Color.white)
                        .frame(width: geo.size.width * CGFloat(user.xpInCurrentLevel) / 1000, height: 10)
                }
            }
            .frame(height: 10)

            HStack {
                Text("\(user.xp) XP")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))
                Spacer()
                Text("\(user.level * 1000) XP")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [greenColor, greenColor.opacity(0.75)],
                startPoint: .top,
                endPoint: .bottom
            ),
            in: RoundedRectangle(cornerRadius: 20)
        )
    }
}

private struct RecommendedCard: View {
    let place: AdditionalPlace
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let photo = place.photo {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 160, height: 120)
                    .clipped()
            } else {
                Color(.systemGray5)
                    .frame(width: 160, height: 120)
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(.secondary)
                    }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(place.displayName)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .lineLimit(1)
                
                Text(place.type.name)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(10)
            .frame(width: 160, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground))
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
