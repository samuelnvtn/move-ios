//
//  PlannerViewModel.swift
//  Move
//
//  Created by David Řihák on 13.06.2026.
//

import SwiftUI
import CoreLocation

@Observable
final class PlannerViewModel {
    var state = PlannerViewState()
    private let dataManager: DataManaging

    init() {
        self.dataManager = DIContainer.shared.resolve()
    }

    func fetchTrips() {
        state.trips = dataManager.fetchTrips()
    }

    func deleteTrip(_ trip: Trip) {
        dataManager.deleteTrip(trip)
        fetchTrips()
    }
    
}
