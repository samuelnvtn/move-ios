//
//  TripPlacePickerViewModel.swift
//  Move
//
//  Created by David Řihák on 14.06.2026.
//

import SwiftUI
import MapKit

@Observable
final class TripPlacePickerViewModel {
    var state = TripPlacePickerViewState()
    private let dataManager: DataManaging
    private let locationManager: LocationManaging
    private var hasCenteredOnUser = false
    private var locationObserver: Any?

    init() {
        self.dataManager = DIContainer.shared.resolve()
        self.locationManager = DIContainer.shared.resolve()
        loadAvailablePlaces()
        centerMapOnUser()
        setupLocationObserver()
    }
    
    private func centerMapOnUser() {
        guard let coords = locationManager.getCurrentLocation() else { return }
        hasCenteredOnUser = true
        state.position = .camera(.init(centerCoordinate: coords, distance: 25000))
    }

    private func setupLocationObserver() {
        locationObserver = NotificationCenter.default.addObserver(
            forName: .locationDidUpdate,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self, !self.hasCenteredOnUser else { return }
            if let coords = notification.object as? CLLocationCoordinate2D {
                self.hasCenteredOnUser = true
                self.state.position = .camera(.init(centerCoordinate: coords, distance: 25000))
            }
        }
    }

    deinit {
        if let locationObserver {
            NotificationCenter.default.removeObserver(locationObserver)
        }
    }

    func loadAvailablePlaces() {
        state.allPlaces = dataManager.fetchPlaces()
    }

    func handlePlaceSelection(_ place: Place) {
        if let index = state.selectedPlaces.firstIndex(where: { $0.id == place.id }) {
            state.selectedPlaces.remove(at: index)
        } else {
            state.selectedPlaces.append(place)
        }
    }
}
