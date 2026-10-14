//
//  PlaceDetailViewModel.swift
//  Move
//
//  Created by David Řihák on 10.06.2026.
//

import SwiftUI

@Observable
final class PlaceDetailViewModel {
    var state: PlaceDetailViewState
    private let dataManager: DataManaging

    var totalXP: Int { state.tasks.reduce(0) { $0 + $1.points } }

    init(place: Place) {
        self.state = PlaceDetailViewState(place: place)
        self.dataManager = DIContainer.shared.resolve()
        loadTasks()
    }

    private func loadTasks() {
        state.tasks = dataManager.fetchTasks(for: state.place.id)
    }

    func toggleTaskCompletion(task: PlaceTask) {
        guard let index = state.tasks.firstIndex(where: { $0.id == task.id }) else { return }
        let wasCompleted = state.tasks[index].isCompleted
        state.tasks[index].isCompleted.toggle()
        dataManager.saveTask(state.tasks[index])

        var user = dataManager.fetchUser()
        if wasCompleted {
            user.xp = max(0, user.xp - state.tasks[index].points)
        } else {
            user.xp += state.tasks[index].points
        }
        dataManager.saveUser(user)

        state.place.points = state.tasks.filter(\.isCompleted).reduce(0) { $0 + $1.points }
        dataManager.savePlace(state.place)
    }
    
    func refreshData() {
        if let freshPlace = dataManager.fetchPlace(id: state.place.id) {
            self.state.place = freshPlace
            loadTasks()
        }
    }

    func markAsVisited() {
        state.place.visited = true
        state.place.visitedOn = Date()
        dataManager.savePlace(state.place)

        var user = dataManager.fetchUser()
        user.xp += 150
        dataManager.saveUser(user)
    }
}
