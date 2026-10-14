//
//  AIItineraryResultViewModel.swift
//  Move
//
//  Created by Samuel Novotný on 15.06.2026.
//

import Foundation
import Observation

@Observable
final class AIItineraryResultViewModel {
    var trip: Trip
    private let dataManager: DataManaging

    init(trip: Trip) {
        self.trip = trip
        self.dataManager = DIContainer.shared.resolve()
    }

    func saveTrip() {
        dataManager.saveTrip(trip)
    }

    func deleteTrip() {
        dataManager.deleteTrip(trip)
    }

    func refreshVisitedStatus() {
        trip.stops = trip.stops.map { stop in
            guard let fresh = dataManager.fetchPlace(id: stop.place.id) else { return stop }
            var updated = stop
            updated.place = fresh
            return updated
        }
    }
}
