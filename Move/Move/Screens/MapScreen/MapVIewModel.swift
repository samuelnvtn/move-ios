//
//  Untitled.swift
//  Move
//
//  Created by David Řihák on 11.06.2026.
//

import SwiftUI
import Foundation
import MapKit

@Observable
final class MapViewModel {

    var state = MapViewState()
    private let dataManager: DataManaging
    private let locationManager: LocationManaging
    private var hasCenteredOnUser = false
    private var locationObserver: Any?
    private var authObserver: Any?

    init() {
        self.dataManager = DIContainer.shared.resolve()
        self.locationManager = DIContainer.shared.resolve()
        loadPlaces()
        
        locationHandler()

        if let userLocation = locationManager.getCurrentLocation() {
            hasCenteredOnUser = true
            state.position = .camera(
                .init(
                    centerCoordinate: userLocation,
                    distance: 45000
                )
            )
            state.centerCoordinate = userLocation
        }

        setupLocationObservers()
    }

    private func setupLocationObservers() {
        authObserver = NotificationCenter.default.addObserver(
            forName: .locationAuthorizationDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.locationHandler()
        }

        locationObserver = NotificationCenter.default.addObserver(
            forName: .locationDidUpdate,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            self.locationHandler()
            if let coordinate = notification.object as? CLLocationCoordinate2D, !self.hasCenteredOnUser {
                self.hasCenteredOnUser = true
                self.state.position = .camera(
                    .init(
                        centerCoordinate: coordinate,
                        distance: 45000
                    )
                )
                self.state.centerCoordinate = coordinate
            }
        }
    }

    deinit {
        if let authObserver {
            NotificationCenter.default.removeObserver(authObserver)
        }
        if let locationObserver {
            NotificationCenter.default.removeObserver(locationObserver)
        }
    }

    func loadPlaces() {
        state.rawPlaces = dataManager.fetchPlaces()
        state.rawAdditionalPlaces = dataManager.fetchAdditionalPlaces()
        updateClusters()
    }

    func updateCenter(_ coordinate: CLLocationCoordinate2D, span: MKCoordinateSpan) {
        state.centerCoordinate = coordinate
        state.zoomLevel = max(span.latitudeDelta, span.longitudeDelta)
        updateClusters()
    }
    
    func updateClusters() {
        let threshold = state.zoomLevel * 0.04
        var newClusters: [MapClusterItem] = []
        
        for place in state.rawPlaces {
            if let index = newClusters.firstIndex(where: { abs($0.coordinate.latitude - place.location.latitude) < threshold && abs($0.coordinate.longitude - place.location.longitude) < threshold }) {
                let current = newClusters[index]
                newClusters[index] = MapClusterItem(coordinate: current.coordinate, places: current.places + [place], additionalPlaces: current.additionalPlaces)
            } else {
                newClusters.append(MapClusterItem(coordinate: place.location, places: [place], additionalPlaces: []))
            }
        }
        
        for additional in state.rawAdditionalPlaces {
            if let index = newClusters.firstIndex(where: { abs($0.coordinate.latitude - additional.location.latitude) < threshold && abs($0.coordinate.longitude - additional.location.longitude) < threshold }) {
                let current = newClusters[index]
                newClusters[index] = MapClusterItem(coordinate: current.coordinate, places: current.places, additionalPlaces: current.additionalPlaces + [additional])
            } else {
                newClusters.append(MapClusterItem(coordinate: additional.location, places: [], additionalPlaces: [additional]))
            }
        }
        
        state.clusters = newClusters
        state.places = newClusters.filter { $0.count == 1 }.flatMap { $0.places }
        state.additionalPlaces = newClusters.filter { $0.count == 1 }.flatMap { $0.additionalPlaces }
    }
    
    func selectPlace(_ place: Place?) {
        state.selectedPlace = place
    }
    
    func selectAdditionalPlace(_ additionalPlace: AdditionalPlace?) {
        state.selectedAdditionalPlace = additionalPlace
    }
    
    func selectCluster(_ cluster: MapClusterItem?) {
        state.selectedCluster = cluster
    }
    
    func handlePlaceSelectionFromCluster(_ place: Place) async {
        state.selectedCluster = nil
        try? await Task.sleep(for: .seconds(0.2))
        state.selectedPlace = place
    }
    
    func handleAdditionalPlaceSelectionFromCluster(_ additionalPlace: AdditionalPlace) async {
        state.selectedCluster = nil
        try? await Task.sleep(for: .seconds(0.2))
        state.selectedAdditionalPlace = additionalPlace
    }
    
    func regenerateCurrentArea() {
        let placesDataService: PlacesDataServicing = DIContainer.shared.resolve()
        
        withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
            state.isRegenerating = true
        }
        
        Task {
            dataManager.deleteAdditionalPlaces()
            await placesDataService.seedRemainingPlaces(maxPlaces: 40, amountPerTheme: 10, radiusM: 7000, lat: state.centerCoordinate.latitude, lng: state.centerCoordinate.longitude)
            await MainActor.run {
                withAnimation(.spring) {
                    state.isRegenerating = false
                }
                loadPlaces()
            }
        }
    }
    
    func convertAndSaveToMainPlaces(additionalPlace: AdditionalPlace) {
        let newPlace = Place(
            id: UUID(),
            name: additionalPlace.displayName,
            group: "Objevené",
            description: additionalPlace.formattedAddress,
            location: additionalPlace.location,
            type: additionalPlace.type,
            photo: additionalPlace.photo,
            timeTo: nil,
            locationTime: 60,
            price: 0,
            visited: true,
            points: 0,
            difficulty: .easy,
            visitedOn: Date()
        )
        
        dataManager.savePlace(newPlace)
        dataManager.deleteAdditionalPlace(additionalPlace)
        loadPlaces()
    }
    
    func locationHandler() {
        state.isLocationAuthorized = locationManager.isLocationAuthorized()
    }
}
