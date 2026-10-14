//
//  DataManaging.swift
//  Move
//
//  Created by David Řihák on 11.06.2026.
//

import Foundation

protocol DataManaging {
    func savePlace(_ place: Place)
    func fetchPlaces() -> [Place]
    func fetchPlace(id: UUID) -> Place?
    func deletePlace(_ place: Place)
        
    func saveTask(_ task: PlaceTask)
    func saveTasks(_ tasks: [PlaceTask])
    func fetchTasks() -> [PlaceTask]
    func fetchTasks(for placeId: UUID) -> [PlaceTask] 
    func deleteTask(_ task: PlaceTask)
    func deleteTasks(for placeId: UUID)
    
    func fetchUser() -> User
    func saveUser(_ user: User)
    
    func saveTrip(_ trip: Trip)
    func fetchTrips() -> [Trip]
    func deleteTrip(_ trip: Trip)
    
    func saveAdditionalPlace(_ place: AdditionalPlace)
    func fetchAdditionalPlaces() -> [AdditionalPlace]
    func deleteAdditionalPlace(_ place: AdditionalPlace)
    func deleteAdditionalPlaces()
}
