//
//  MyPlacesViewModel.swift
//  Move
//
//  Created by David Řihák on 10.06.2026.
//

import SwiftUI
import CoreLocation

@Observable
final class MyPlacesViewModel {
    var state = MyPlacesViewState()
    private let dataManager: DataManaging
    private let placesService: PlacesServicing

    init() {
        self.dataManager = DIContainer.shared.resolve()
        self.placesService = DIContainer.shared.resolve()
        loadData()
    }

    var sortedGroupedPlaces: [(group: String, places: [Place])] {
        Dictionary(grouping: state.filteredPlaces, by: \.group)
            .map { (group: $0.key, places: $0.value) }
            .sorted { $0.group < $1.group }
    }

    func loadData() {
        state.allPlaces = dataManager.fetchPlaces()
        applyFilter()
        
        if let currentId = state.selectedPlace?.id {
            let freshPlace = state.allPlaces.first(where: { $0.id == currentId })
            state.selectedPlace = nil
            state.selectedPlace = freshPlace
        }
    }

    func selectFilter(_ filter: FilterEnum) {
        state.selectedFilter = filter
        applyFilter()
    }

    func changeSort(to option: SortOption) {
        state.selectedSort = option
        applyFilter()
    }

    func applyFilter() {
        let basePlaces = state.allPlaces.filter { $0.visited == (state.selectedFilter == .history) }
        
        let query = state.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let filtered = query.isEmpty ? basePlaces : basePlaces.filter { place in
            place.name.localizedStandardContains(query) || place.group.localizedStandardContains(query)
        }
        
        state.filteredPlaces = filtered.sorted { lhs, rhs in
            switch state.selectedSort {
            case .name:  return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
            case .group: return lhs.group.localizedStandardCompare(rhs.group) == .orderedAscending
            }
        }
    }

    func selectPlace(_ place: Place?) {
        state.selectedPlace = place
    }
    

    func makeListItem(from place: Place) -> PlaceListItem {
        PlaceListItem(
            id: place.id,
            title: place.name,
            subtitle: place.type.name.capitalized,
            image: place.photo
        )
    }
    
    func deletePlace(at offsets: IndexSet, inside section: (group: String, places: [Place])) {
        offsets.forEach { dataManager.deletePlace(section.places[$0]) }
        loadData()
    }
    
}

enum SortOption {
    case name
    case group
}
