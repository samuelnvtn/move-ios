//
//  TripPlacePickerViewState.swift
//  Move
//
//  Created by David Řihák on 14.06.2026.
//

import SwiftUI
import MapKit

@Observable
final class TripPlacePickerViewState {
    var position: MapCameraPosition = .camera(
        .init(
            centerCoordinate: .init(latitude: 49.209, longitude: 16.614),
            distance: 2000000
        )
    )
    var allPlaces: [Place] = []
    var selectedPlaces: [Place] = []
}
