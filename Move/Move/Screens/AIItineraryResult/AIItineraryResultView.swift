//
//  AIItineraryResultView.swift
//  Move
//
//  Created by Samuel Novotný on 15.06.2026.
//

import SwiftUI

struct AIItineraryResultView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AIItineraryResultViewModel
    @State private var selectedPlace: Place?

    let isSaved: Bool
    let onTripSaved: () -> Void
    let onTripDeleted: () -> Void
    let onRegenerate: () -> Void

    init(trip: Trip, isSaved: Bool = false, onTripSaved: @escaping () -> Void = {}, onTripDeleted: @escaping () -> Void = {}, onRegenerate: @escaping () -> Void = {}) {
        self._viewModel = State(initialValue: AIItineraryResultViewModel(trip: trip))
        self.isSaved = isSaved
        self.onTripSaved = onTripSaved
        self.onTripDeleted = onTripDeleted
        self.onRegenerate = onRegenerate
    }

    private var trip: Trip { viewModel.trip }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                summaryRow
                    .padding(.horizontal)
                    .padding(.vertical, 12)

                VStack(spacing: 10) {
                    ForEach(Array(trip.stops.enumerated()), id: \.element.id) { index, stop in
                        stopCard(number: index + 1, stop: stop)
                            .onTapGesture { selectedPlace = stop.place }

                        if index < trip.stops.count - 1 && !stop.travelLegs.isEmpty {
                            travelConnector(stop: stop)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("AI Itinerary")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("AI Itinerary")
                    .font(.headline)
                    .foregroundStyle(.green)
            }
            if isSaved {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.deleteTrip()
                        onTripDeleted()
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                }
            } else {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !isSaved { bottomBar }
        }
        .sheet(item: $selectedPlace, onDismiss: { viewModel.refreshVisitedStatus() }) { place in
            PlaceDetailView(place: place)
        }
    }

    private var summaryRow: some View {
        HStack(spacing: 6) {
            Image(systemName: "clock")
            Text("\(trip.stops.count) places in \(trip.city.isEmpty ? "city" : trip.city)")
            Text("•")
            Image(systemName: "mappin.and.ellipse")
            Text(durationText)
            Text("•")
            Image(systemName: "creditcard")
            Text("\(trip.totalCost) CZK")
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }

    private var durationText: String {
        let hours = trip.totalDurationMinutes / 60
        let minutes = trip.totalDurationMinutes % 60
        if hours == 0 { return "\(minutes) min" }
        if minutes == 0 { return "around \(hours) hours" }
        return "around \(hours)h \(minutes)m"
    }

    private func stopCard(number: Int, stop: TripStop) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("\(number). \(stop.place.name)")
                    .font(.headline)
                Spacer()
                if stop.place.visited {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }

            Text("\(stop.place.type.name) • \(stop.place.locationTime) min")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if !stop.note.isEmpty {
                Text(stop.note)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func travelConnector(stop: TripStop) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(stop.travelLegs) { leg in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: travelIcon(for: leg.mode))
                        .foregroundStyle(.green)
                        .frame(width: 16)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(leg.mode)
                            .fontWeight(.medium)
                        if !leg.info.isEmpty {
                            Text(leg.info)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            }
            HStack(spacing: 4) {
                Text("\(stop.travelMinutes) min")
                if stop.travelCost > 0 {
                    Text("· \(stop.travelCost) CZK")
                }
            }
            .foregroundStyle(.secondary)
        }
        .font(.caption)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 14)
    }

    private var bottomBar: some View {
        HStack(spacing: 12) {
            Button {
                viewModel.saveTrip()
                onTripSaved()
            } label: {
                Text("Save Trip")
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.green)
                    .clipShape(Capsule())
            }

            Button {
                dismiss()
                onRegenerate()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(.green)
                    .frame(width: 52, height: 52)
                    .background(Color(.systemBackground))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.green.opacity(0.4), lineWidth: 1.5))
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 24)
        .background(Color(.systemGroupedBackground))
    }

    private func travelIcon(for mode: String) -> String {
        let lower = mode.lowercased()
        if lower.hasPrefix("walk") { return "figure.walk" }
        if lower.hasPrefix("train") || lower.hasPrefix("ic ") || lower.hasPrefix("ec ") || lower.hasPrefix("sc ") || lower.hasPrefix("rex") { return "train.side.front.car" }
        if lower.hasPrefix("bus") { return "bus.fill" }
        if lower.hasPrefix("tram") { return "tram.fill" }
        if lower.hasPrefix("metro") || lower.hasPrefix("subway") { return "tram.fill" }
        if lower.hasPrefix("car") || lower.hasPrefix("driv") { return "car.fill" }
        if lower.hasPrefix("bike") || lower.hasPrefix("cycl") { return "bicycle" }
        return "figure.walk"
    }
}
