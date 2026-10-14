//
//  HomeScreenViewModel.swift
//  Move
//
//  Created by Samuel Novotný on 09.06.2026.
//

import Foundation
import Observation

@Observable
final class HomeViewModel {

    var state = HomeViewState()
    private let dataManager: DataManaging

    init() {
        self.dataManager = DIContainer.shared.resolve()
        loadAllData()
    }

    func loadAllData() {
        state.user = dataManager.fetchUser()
        
        let places = dataManager.fetchPlaces()
        let visitedPlaces = places.filter { $0.visited }
        
        let allBadges = PlaceType.allCases.map { type in
            StatsBadge(
                title: type.name,
                icon: type.sfSymbol,
                count: visitedPlaces.filter { $0.type == type }.count
            )
        }
        state.achievements = Array(allBadges.sorted(by: { $0.count > $1.count }).prefix(3))
        
        let additionals = dataManager.fetchAdditionalPlaces()
        state.recommendedPlaces = Array(additionals.shuffled().prefix(5))
    }
}
