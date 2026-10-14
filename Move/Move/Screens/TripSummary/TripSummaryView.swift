//
//  TripSummaryView.swift
//  Move
//
//  Created by David Řihák on 14.06.2026.
//

import SwiftUI

struct TripSummaryView: View {
    @State private var viewModel: TripSummaryViewModel
    @State private var showResult = false
    @Environment(\.dismiss) private var dismiss

    let onTripSaved: () -> Void

    init(places: [Place], onTripSaved: @escaping () -> Void) {
        self._viewModel = State(initialValue: TripSummaryViewModel(places: places))
        self.onTripSaved = onTripSaved
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        ZStack {
                            Text("AI Itinerary")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(.green)
                                .frame(maxWidth: .infinity)

                            HStack {
                                Button("Cancel") { dismiss() }
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)

                        cardSection(title: "Custom prompt") {
                            TextField("E.g. walk to places which are close to each other", text: $viewModel.state.preferences, axis: .vertical)
                                .padding()
                        }

                        cardSection(title: "Travel methods") {
                            TextField("E.g. walking, public transport...", text: $viewModel.state.travelMethods)
                                .padding()
                        }

                        placesSection
                    }
                    .padding(.bottom, 96)
                }

                generateButton
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showResult) {
                if let trip = viewModel.state.generatedTrip {
                    AIItineraryResultView(
                        trip: trip,
                        onTripSaved: onTripSaved,
                        onRegenerate: {
                            showResult = false
                            viewModel.state.generatedTrip = nil
                            Task { await viewModel.generateItinerary() }
                        }
                    )
                }
            }
            .onChange(of: viewModel.state.generatedTrip?.id) { _, newValue in
                if newValue != nil { showResult = true }
            }
            .alert("Generation Failed", isPresented: $viewModel.state.isShowingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.state.errorMessage ?? "")
            }
        }
    }

    private var placesSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Places to visit")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 20)

            List {
                ForEach(viewModel.state.places) { place in
                    HStack(spacing: 12) {
                        if let photo = place.photo {
                            Image(uiImage: photo)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 46, height: 46)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray4))
                                .frame(width: 46, height: 46)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                )
                        }
                        Text(place.name)
                            .font(.body)
                    }
                    .padding(.vertical, 4)
                    .listRowBackground(Color(.secondarySystemGroupedBackground))
                    .listRowInsets(EdgeInsets(top: 0, leading: 14, bottom: 0, trailing: 14))
                    .listRowSeparatorTint(Color(.systemGray5))
                }
            }
            .listStyle(.plain)
            .frame(height: CGFloat(viewModel.state.places.count) * 68)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    private func cardSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 20)

            content()
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
        }
    }

    private var generateButton: some View {
        Button {
            Task { await viewModel.generateItinerary() }
        } label: {
            Group {
                if viewModel.state.isGenerating {
                    HStack(spacing: 8) {
                        ProgressView().tint(.white)
                        Text("Generating...")
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        Image(systemName: "sparkles")
                            .foregroundStyle(.white)
                    }
                } else {
                    Text("Generate Trip")
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(viewModel.state.isGenerating ? Color.green.opacity(0.7) : Color.green)
            .clipShape(Capsule())
        }
        .disabled(viewModel.state.isGenerating || viewModel.state.places.isEmpty)
        .padding(.horizontal)
        .padding(.bottom, 32)
    }
}
