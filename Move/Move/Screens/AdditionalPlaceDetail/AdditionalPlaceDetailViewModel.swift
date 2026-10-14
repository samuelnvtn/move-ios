//
//  AdditionalPlaceDetailViewModel.swift
//  Move
//
//  Created by David Řihák on 14.06.2026.
//

import SwiftUI

@Observable
final class AdditionalPlaceDetailViewModel {
    var state: AdditionalPlaceDetailViewState
    private let dataManager: DataManaging
    private let placesDataService: PlacesDataServicing
    private let locationManager: LocationManaging
    private let geminiService: GeminiServicing

    init(additionalPlace: AdditionalPlace) {
        self.state = .init(additionalPlace: additionalPlace)
        self.dataManager = DIContainer.shared.resolve()
        self.placesDataService = DIContainer.shared.resolve()
        self.locationManager = DIContainer.shared.resolve()
        self.geminiService = DIContainer.shared.resolve()
    }

    func addAdditionalPlace() async -> Bool {
        state.isLoading = true
        defer { state.isLoading = false }

        let calculatedGroup = await locationManager.getLocationDistrict(state.additionalPlace.location)
        let groupName = calculatedGroup.isEmpty ? "Unknown" : calculatedGroup
        let placeId = UUID()

        var locationTime = 60
        var difficulty: PlaceDifficulty = .easy
        var price = 0
        var tasksToSave: [PlaceTask] = []

        do {
            let placeData = try await geminiService.generatePlaceData(for: state.additionalPlace, placeId: placeId)
            locationTime = placeData.locationTime
            difficulty = placeData.difficulty
            price = placeData.price
            tasksToSave = placeData.tasks
            print("Gemini: locationTime=\(locationTime)min, difficulty=\(difficulty), price=\(price), tasks=\(placeData.tasks.map(\.title))")
        } catch {
            state.isShowingAIWarning = true
            print("Gemini generatePlaceData failed: \(error)")
        }

        let newPlace = Place(
            id: placeId,
            name: state.additionalPlace.displayName,
            group: groupName,
            description: state.additionalPlace.formattedAddress,
            location: state.additionalPlace.location,
            type: state.additionalPlace.type,
            photo: state.additionalPlace.photo,
            timeTo: nil,
            locationTime: locationTime,
            price: price,
            visited: false,
            points: 0,
            difficulty: difficulty,
            visitedOn: Date(),
            googleId: state.additionalPlace.googleId
        )

        dataManager.savePlace(newPlace)
        if !tasksToSave.isEmpty {
            dataManager.saveTasks(tasksToSave)
        }

        dataManager.deleteAdditionalPlace(state.additionalPlace)

        Task(priority: .background) {
            await placesDataService.seedRemainingPlaces(maxPlaces: 40, amountPerTheme: 10, radiusM: 7000)

            await MainActor.run {
                NotificationCenter.default.post(name: NSNotification.Name("RefreshAdditionalPlaces"), object: nil)
            }
        }

        return true
    }
}
