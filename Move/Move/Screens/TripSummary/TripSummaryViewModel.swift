//
//  TripSummaryViewModel.swift
//  Move
//
//  Created by David Řihák on 14.06.2026.
//

import Foundation
import Observation

@Observable
final class TripSummaryViewModel {
    var state: TripSummaryViewState
    private let geminiService: GeminiServicing

    init(places: [Place]) {
        self.state = TripSummaryViewState(places: places)
        self.geminiService = DIContainer.shared.resolve()
    }

    func generateItinerary() async {
        state.isGenerating = true
        defer { state.isGenerating = false }

        do {
            let trip = try await geminiService.generateTripItinerary(
                places: state.places,
                preferences: state.preferences,
                travelMethods: state.travelMethods
            )
            state.generatedTrip = trip
            print("✅ Gemini trip: \(trip.name), \(trip.stops.count) stops, \(trip.city)")
        } catch {
            state.errorMessage = "Failed to generate itinerary. Check your internet connection and try again."
            state.isShowingError = true
            print("❌ Gemini generateTripItinerary failed: \(error)")
        }
    }
}
