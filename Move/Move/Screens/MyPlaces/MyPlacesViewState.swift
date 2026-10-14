//
//  MyPlacesViewState.swift
//  Move
//
//  Created by David Řihák on 10.06.2026.
//

import SwiftUI

@Observable
final class MyPlacesViewState {
    var selectedFilter: FilterEnum = .myPlaces
    var allPlaces: [Place] = []
    var filteredPlaces: [Place] = []
    var selectedPlace: Place?
    var searchText: String = ""
    var selectedSort: SortOption = .name
    var activeSheet: ActiveSheet?
}

enum ActiveSheet: Identifiable, Equatable {
    case detail(Place)
    case edit(UUID)
    
    var id: String {
        switch self {
        case .detail(let place): return "detail-\(place.id.uuidString)"
        case .edit(let id): return "edit-\(id.uuidString)"
        }
    }
}

enum FilterEnum: String, CaseIterable {
    case myPlaces = "To Visit"
    case history = "Visited"
}
