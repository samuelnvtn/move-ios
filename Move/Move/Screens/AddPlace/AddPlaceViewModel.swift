//
//  AddPlaceViewModel.swift
//  Move
//
//  Created by David Řihák on 10.06.2026.
//

import SwiftUI
import CoreLocation

@Observable
final class AddPlaceViewModel {

    var state = AddPlaceViewState()
    private let dataManager: DataManaging
    private let locationManager: LocationManaging

    init(location: CLLocationCoordinate2D, place: Place? = nil) {
        self.dataManager = DIContainer.shared.resolve()
        self.locationManager = DIContainer.shared.resolve()
        
        if let placeToLoad = place {
            state.isEditing = !placeToLoad.name.isEmpty
            
            self.state.place = placeToLoad
            self.state.tasks = dataManager.fetchTasks(for: placeToLoad.id)
            
            if let firstTime = placeToLoad.locationTime as Int?, firstTime > 0 {
                self.state.locationTimeString = String(firstTime)
            }
            if let firstPrice = placeToLoad.price as Int?, firstPrice > 0 {
                self.state.priceString = String(firstPrice)
            }
        } else {
            state.isEditing = false
            self.state.place.location = location
        }
    }

    func deleteCurrentPlace() {
        dataManager.deletePlace(state.place)
    }
    
    func addTask() {
        let trimmed = state.newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let newTask = PlaceTask(
            id: UUID(),
            placeId: state.place.id,
            title: trimmed,
            isCompleted: false,
            points: state.newTaskPoints
        )
        
        state.tasks.append(newTask)
        state.newTaskTitle = ""
        state.newTaskPoints = 20
    }

    func save() async -> Bool {
        guard !state.place.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }

        state.place.group = await locationManager.getLocationDistrict(state.place.location)
        state.place.locationTime = Int(state.locationTimeString) ?? 0
        state.place.price = Int(state.priceString) ?? 0
        state.place.difficulty = .custom
        state.place.points = state.tasks.filter(\.isCompleted).reduce(0) { $0 + $1.points }

        dataManager.savePlace(state.place)
        dataManager.saveTasks(state.tasks)
        
        return true
    }

    func removeTask(_ task: PlaceTask) {
        state.tasks.removeAll { $0.id == task.id }
    }

    func toggleTask(_ task: PlaceTask) {
        guard let index = state.tasks.firstIndex(where: { $0.id == task.id }) else { return }
        state.tasks[index].isCompleted.toggle()
    }
    
    func updateTaskPoints(for task: PlaceTask, to newPoints: Int) {
        guard let index = state.tasks.firstIndex(where: { $0.id == task.id }) else { return }
        state.tasks[index].points = newPoints
    }
}
