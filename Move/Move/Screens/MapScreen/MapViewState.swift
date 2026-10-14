//
//  MapViewState.swift
//  Move
//
//  Created by David Řihák on 11.06.2026.
//

import SwiftUI
import MapKit

@Observable
final class MapViewState {
    var position: MapCameraPosition = .camera(
        .init(
            centerCoordinate: .init(latitude: 49.800900999999996, longitude: 15.478152499999993),
            distance: 2000000
        )
    )
    var centerCoordinate = CLLocationCoordinate2D(latitude: 49.1951, longitude: 16.6068)
    var zoomLevel: Double = 0.05
    var places: [Place] = []
    var additionalPlaces: [AdditionalPlace] = []
    var clusters: [MapClusterItem] = []
    
    var rawPlaces: [Place] = []
    var rawAdditionalPlaces: [AdditionalPlace] = []
    
    var selectedPlace: Place? = nil
    var selectedAdditionalPlace: AdditionalPlace? = nil
    var selectedCluster: MapClusterItem? = nil
    
    var isRegenerating: Bool = false
    var isLocationAuthorized: Bool = false
}

struct MapClusterItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let places: [Place]
    let additionalPlaces: [AdditionalPlace]
    
    var count: Int {
        places.count + additionalPlaces.count
    }
}
