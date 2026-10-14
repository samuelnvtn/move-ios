//
//  ContentViewModel.swift
//  Move
//
//  Created by David Řihák on 14.06.2026.
//
import SwiftUI
import Foundation
@Observable
final class ContentViewModel {
    var placesDataService: PlacesDataServicing
    var dataManager: DataManaging
    
    init() {
        self.placesDataService = DIContainer.shared.resolve()
        self.dataManager = DIContainer.shared.resolve()
    }
    
    func onAppStart() {
        Task {
            dataManager.deleteAdditionalPlaces()
            await placesDataService.seedRemainingPlaces(maxPlaces: 40, amountPerTheme: 10, radiusM: 7000)
            
            await MainActor.run {
                NotificationCenter.default.post(name: NSNotification.Name("RefreshAdditionalPlaces"), object: nil)
            }
        }
    }
}
