//
//  CoreDataManager.swift
//  Move
//
//  Created by David Řihák on 11.06.2026.
//

import SwiftUI
import CoreData
import MapKit

final class CoreDataManager: DataManaging {
    
    
    private let container = NSPersistentContainer(name: "Move")
    private var context: NSManagedObjectContext { container.viewContext }
    
    init() {
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Core Data failed to create container: \(error.localizedDescription)")
            }
        }
    }
    
    func savePlace(_ place: Place) {
        let request = NSFetchRequest<PlaceEntity>(entityName: "PlaceEntity")
        request.predicate = NSPredicate(format: "id == %@", place.id as CVarArg)

        do {
            let results = try context.fetch(request)
            let entity = results.first ?? PlaceEntity(context: context)
            entity.id = place.id
            entity.name = place.name
            entity.group = place.group
            entity.desc = place.description
            entity.latitude = place.location.latitude
            entity.longitude = place.location.longitude
            entity.type = place.type.rawValue
            if let photo = place.photo {
                entity.photoData = photo.pngData()
            }
            if let currentplaceTimeTo: Int = place.timeTo {
                entity.timeTo = Int16(currentplaceTimeTo)
            }
            entity.locationTime = Int16(place.locationTime)
            entity.price = Int16(place.price)
            entity.visited = place.visited
            entity.points = Int16(place.points)
            entity.difficulty = place.difficulty.rawValue
            entity.visitedOn = place.visitedOn
            entity.googleId = place.googleId
            
            save()
        } catch {
            print("CoreDataManager savePlace error: \(error.localizedDescription)")
        }
    }
    
    func fetchPlaces() -> [Place] {
        let request = NSFetchRequest<PlaceEntity>(entityName: "PlaceEntity")

        do {
            let entities = try context.fetch(request)

            return entities.map { entity in
                var loadedPhoto: UIImage? = nil
                if let photoData = entity.photoData {
                    loadedPhoto = UIImage(data: photoData)
                }

                return Place(id: entity.id ?? UUID(),
                             name: entity.name ?? "",
                             group: entity.group ?? "",
                             description: entity.desc ?? "",
                             location: .init(latitude: entity.latitude, longitude: entity.longitude),
                             type: PlaceType(rawValue: entity.type) ?? .landmark,
                             photo: loadedPhoto,
                             locationTime: Int(entity.locationTime),
                             price: Int(entity.price),
                             visited: entity.visited,
                             points: Int(entity.points),
                             difficulty: PlaceDifficulty(rawValue: entity.difficulty) ?? .custom,
                             visitedOn: entity.visitedOn)
            }
        } catch {
            print("CoreDataManager fetchPlaces error: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchPlace(id: UUID) -> Place? {
        let request = NSFetchRequest<PlaceEntity>(entityName: "PlaceEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            guard let entity = try context.fetch(request).first else { return nil }
            
            var loadedPhoto: UIImage? = nil
            if let photoData = entity.photoData {
                loadedPhoto = UIImage(data: photoData)
            }
            
            return Place(
                id: entity.id ?? UUID(),
                name: entity.name ?? "",
                group: entity.group ?? "",
                description: entity.desc ?? "",
                location: .init(latitude: entity.latitude, longitude: entity.longitude),
                type: PlaceType(rawValue: entity.type) ?? .landmark,
                photo: loadedPhoto,
                locationTime: Int(entity.locationTime),
                price: Int(entity.price),
                visited: entity.visited,
                points: Int(entity.points),
                difficulty: PlaceDifficulty(rawValue: entity.difficulty) ?? .custom,
                visitedOn: entity.visitedOn
            )
        } catch {
            print("CoreDataManager fetchPlace(id:) error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func deletePlace(_ place: Place) {
        let request = NSFetchRequest<PlaceEntity>(entityName: "PlaceEntity")
        request.predicate = NSPredicate(format: "id == %@", place.id as CVarArg)
        
        if let entity = try? context.fetch(request).first {
            context.delete(entity)
            save()
        }
    }
    
    // MARK: tasks
    
    func saveTask(_ task: PlaceTask) {
        saveTasks([task])
    }
    
    func saveTasks(_ tasks: [PlaceTask]) {
        guard !tasks.isEmpty else { return }
        
        let targetPlaceId = tasks[0].placeId
        
        let placeRequest = NSFetchRequest<PlaceEntity>(entityName: "PlaceEntity")
        placeRequest.predicate = NSPredicate(format: "id == %@", targetPlaceId as CVarArg)
        
        guard let parentPlaceEntity = try? context.fetch(placeRequest).first else {
            print("Error: Trying to save non-existing place")
            return
        }
        
        for task in tasks {
            let request = NSFetchRequest<PlaceTaskEntity>(entityName: "PlaceTaskEntity")
            request.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
            
            do {
                let results = try context.fetch(request)
                let entity = results.first ?? PlaceTaskEntity(context: context)
                
                entity.id = task.id
                entity.title = task.title
                entity.isCompleted = task.isCompleted
                entity.points = Int16(task.points)
                
                entity.place = parentPlaceEntity
            } catch {
                print("CoreDataManager saveTasks error: \(error.localizedDescription)")
            }
        }
        
        save()
    }
        
    func fetchTasks() -> [PlaceTask] {
        let request = NSFetchRequest<PlaceTaskEntity>(entityName: "PlaceTaskEntity")
        
        do {
            let entities = try context.fetch(request)
            return entities.map { entity in
                return PlaceTask(
                    id: entity.id ?? UUID(),
                    placeId: entity.place?.id ?? UUID(),
                    title: entity.title ?? "",
                    isCompleted: entity.isCompleted,
                    points: Int(entity.points)
                )
            }
        } catch {
            print("CoreDataManager fetchTasks error: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchTasks(for placeId: UUID) -> [PlaceTask] {
        let request = NSFetchRequest<PlaceTaskEntity>(entityName: "PlaceTaskEntity")
        request.predicate = NSPredicate(format: "place.id == %@", placeId as CVarArg)
        
        do {
            let entities = try context.fetch(request)
            return entities.map { entity in
                PlaceTask(
                    id: entity.id ?? UUID(),
                    placeId: placeId,
                    title: entity.title ?? "",
                    isCompleted: entity.isCompleted,
                    points: Int(entity.points)
                )
            }
        } catch {
            print("CoreDataManager fetchTasks(for:) error: \(error.localizedDescription)")
            return []
        }
    }
        
    func deleteTask(_ task: PlaceTask) {
        let request = NSFetchRequest<PlaceTaskEntity>(entityName: "PlaceTaskEntity")
        request.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
        
        if let entity = try? context.fetch(request).first {
            context.delete(entity)
            save()
        }
    }
    
    func deleteTasks(for placeId: UUID) {
        let request = NSFetchRequest<PlaceTaskEntity>(entityName: "PlaceTaskEntity")
        request.predicate = NSPredicate(format: "place.id == %@", placeId as CVarArg)
        
        do {
            let entities = try context.fetch(request)
            for entity in entities {
                context.delete(entity)
            }
            save()
        } catch {
            print("CoreDataManager deleteTasks(for:) error: \(error.localizedDescription)")
        }
    }
    
    
    // MARK: Trips
    
    func saveTrip(_ trip: Trip) {
        let tripEntity = TripEntity(context: context)
        tripEntity.id = trip.id
        tripEntity.name = trip.name
        tripEntity.city = trip.city
        tripEntity.totalDurationMinutes = Int16(trip.totalDurationMinutes)
        tripEntity.totalCost = Int16(trip.totalCost)

        for stop in trip.stops {
            let stopEntity = TripStopEntity(context: context)
            stopEntity.id = stop.id
            stopEntity.index = Int16(stop.index)
            stopEntity.note = stop.note
            stopEntity.travelLegsJSON = try? String(data: JSONEncoder().encode(stop.travelLegs), encoding: .utf8)
            stopEntity.travelMinutes = Int16(stop.travelMinutes)
            stopEntity.travelCost = Int16(stop.travelCost)
            stopEntity.trip = tripEntity

            let request = NSFetchRequest<PlaceEntity>(entityName: "PlaceEntity")
            request.predicate = NSPredicate(format: "id == %@", stop.place.id as CVarArg)
            if let placeEntity = try? context.fetch(request).first {
                stopEntity.place = placeEntity
            }
        }

        save()
    }
    
    func deleteTrip(_ trip: Trip) {
        let request = NSFetchRequest<TripEntity>(entityName: "TripEntity")
        request.predicate = NSPredicate(format: "id == %@", trip.id as CVarArg)
        
        if let entity = try? context.fetch(request).first {
            context.delete(entity)
            save()
        }
    }
    
    func fetchTrips() -> [Trip] {
        let request = NSFetchRequest<TripEntity>(entityName: "TripEntity")

        do {
            return try context.fetch(request).map { tripEntity in
                let stopEntities = tripEntity.stops as? Set<TripStopEntity> ?? []

                let sortedStops = stopEntities.compactMap { stopEntity -> TripStop? in
                    guard let placeEntity = stopEntity.place else { return nil }
                    let legs: [TravelLeg] = {
                        guard let json = stopEntity.travelLegsJSON,
                              let data = json.data(using: .utf8),
                              let decoded = try? JSONDecoder().decode([TravelLeg].self, from: data)
                        else { return [] }
                        return decoded
                    }()
                    return TripStop(
                        id: stopEntity.id ?? UUID(),
                        index: Int(stopEntity.index),
                        place: mapPlaceEntityToPlace(placeEntity),
                        note: stopEntity.note ?? "",
                        travelLegs: legs,
                        travelMinutes: Int(stopEntity.travelMinutes),
                        travelCost: Int(stopEntity.travelCost)
                    )
                }
                .sorted { $0.index < $1.index }

                return Trip(
                    id: tripEntity.id ?? UUID(),
                    name: tripEntity.name ?? "",
                    city: tripEntity.city ?? "",
                    totalDurationMinutes: Int(tripEntity.totalDurationMinutes),
                    totalCost: Int(tripEntity.totalCost),
                    stops: sortedStops
                )
            }
        } catch {
            print("CoreDataManager fetchTrips error: \(error.localizedDescription)")
            return []
        }
    }
        
    private func mapPlaceEntityToPlace(_ entity: PlaceEntity) -> Place {
        var loadedPhoto: UIImage? = nil
        if let photoData = entity.photoData {
            loadedPhoto = UIImage(data: photoData)
        }
        
        var mappedTimeTo: Int? = nil
        if entity.timeTo > 0 {
            mappedTimeTo = Int(entity.timeTo)
        }
        
        return Place(
            id: entity.id ?? UUID(),
            name: entity.name ?? "",
            group: entity.group ?? "",
            description: entity.desc ?? "",
            location: .init(latitude: entity.latitude, longitude: entity.longitude),
            type: PlaceType(rawValue: entity.type) ?? .landmark,
            photo: loadedPhoto,
            timeTo: mappedTimeTo,
            locationTime: Int(entity.locationTime),
            price: Int(entity.price),
            visited: entity.visited,
            points: Int(entity.points),
            difficulty: PlaceDifficulty(rawValue: entity.difficulty) ?? .custom,
            visitedOn: entity.visitedOn,
            googleId: entity.googleId
        )
    }
    
    
    func saveAdditionalPlace(_ place: AdditionalPlace) {
        let request = NSFetchRequest<AdditionalPlaceEntity>(entityName: "AdditionalPlaceEntity")
        request.predicate = NSPredicate(format: "id == %@", place.id as CVarArg)

        do {
            let results = try context.fetch(request)
            let entity = results.first ?? AdditionalPlaceEntity(context: context)
            
            entity.id = place.id
            entity.displayName = place.displayName
            entity.formattedAddress = place.formattedAddress
            entity.googleId = place.googleId
            entity.latitude = place.location.latitude
            entity.longitude = place.location.longitude
            entity.type = place.type.rawValue
            
            if let photo = place.photo {
                entity.photo = photo.pngData()
            } else {
                entity.photo = nil
            }
            
            save()
        } catch {
            print("CoreDataManager saveAdditionalPlace error: \(error.localizedDescription)")
        }
    }

    func fetchAdditionalPlaces() -> [AdditionalPlace] {
        let request = NSFetchRequest<AdditionalPlaceEntity>(entityName: "AdditionalPlaceEntity")
        do {
            let entities = try context.fetch(request)
            return entities.map { entity in
                var loadedPhoto: UIImage? = nil
                if let photoData = entity.photo {
                    loadedPhoto = UIImage(data: photoData)
                }
                
                return AdditionalPlace(
                    id: entity.id ?? UUID(),
                    displayName: entity.displayName ?? "",
                    formattedAddress: entity.formattedAddress ?? "",
                    googleId: entity.googleId ?? "",
                    location: .init(latitude: entity.latitude, longitude: entity.longitude),
                    photo: loadedPhoto,
                    type: PlaceType(rawValue: entity.type) ?? .landmark
                )
            }
        } catch {
            print("CoreDataManager fetchAdditionalPlaces error: \(error.localizedDescription)")
            return []
        }
    }
    
    func deleteAdditionalPlaces() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AdditionalPlaceEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            save()
            print("Database flush: All old AdditionalPlaces removed.")
        } catch {
            print("CoreDataManager clearAdditionalPlaces error: \(error.localizedDescription)")
        }
    }
    
    func deleteAdditionalPlace(_ place: AdditionalPlace) {
        let request = NSFetchRequest<AdditionalPlaceEntity>(entityName: "AdditionalPlaceEntity")
        request.predicate = NSPredicate(format: "id == %@", place.id as CVarArg)
        
        do {
            if let entity = try context.fetch(request).first {
                context.delete(entity)
                save()
                print("AdditionalPlace removed")
            }
        } catch {
            print("CoreDataManager deleteAdditionalPlace error: \(error.localizedDescription)")
        }
    }
    
    
    
}

    // MARK: Private methods
private extension CoreDataManager {
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Cannot save MOC: \(error.localizedDescription)")
            }
        }
    }
    
    /*
    
    func seedInitialDataIfNeeded() {
        let request = NSFetchRequest<PlaceEntity>(entityName: "PlaceEntity")
        let currentCount = (try? context.count(for: request)) ?? 0
        
        if currentCount == 0 {
            let samplePlaces: [(
                name: String,
                group: String,
                desc: String,
                lat: Double,
                lon: Double,
                type: PlaceType,
                difficulty: PlaceDifficulty
            )] = [
                (name: "Pražský hrad", group: "Praha", desc: "Největší starobylý hrad na světě.", lat: 50.091, lon: 14.402, type: .landmark, difficulty: .easy),
                (name: "Café Louvré", group: "Praha", desc: "Historická kavárna v centru Prahy.", lat: 50.082, lon: 14.419, type: .restaurant, difficulty: .easy),
                (name: "Národní muzeum", group: "Praha", desc: "Významná dominant Václavského náměstí.", lat: 50.079, lon: 14.430, type: .landmark, difficulty: .easy),
                (name: "Karlštejn", group: "Střední Čechy", desc: "Gotický hrad založený Karlem IV.", lat: 49.939, lon: 14.184, type: .landmark, difficulty: .medium),
                (name: "Lomy Amerika", group: "Střední Čechy", desc: "Soustava vápencových lomů.", lat: 49.957, lon: 14.195, type: .activity, difficulty: .medium)
            ]
            
            for (name, group, desc, lat, lon, type, difficulty) in samplePlaces {
                let placeEntity = PlaceEntity(context: context)
                placeEntity.id = UUID()
                placeEntity.name = name
                placeEntity.group = group
                placeEntity.desc = desc
                placeEntity.latitude = lat
                placeEntity.longitude = lon
                placeEntity.type = type.rawValue
                placeEntity.difficulty = difficulty.rawValue
                
                placeEntity.locationTime = 60
                placeEntity.price = 0
                placeEntity.visited = false
                placeEntity.points = 10
                
                let task1 = PlaceTaskEntity(context: context)
                task1.id = UUID()
                task1.title = "Udělat fotku před vstupem"
                task1.isCompleted = false
                task1.points = 5
                task1.place = placeEntity
                
                let task2 = PlaceTaskEntity(context: context)
                task2.id = UUID()
                task2.title = "Zjistit historickou zajímavost"
                task2.isCompleted = false
                task2.points = 5
                task2.place = placeEntity
            }
            
            save()
        }
        
        self.seedInitialTripsIfNeeded()
        print("All data checked/seeded successfully.")
    }
    
    func seedInitialTripsIfNeeded() {
        let tripCheckRequest = NSFetchRequest<TripEntity>(entityName: "TripEntity")
        guard let count = try? context.count(for: tripCheckRequest), count == 0 else { return }
        
        let placeRequest = NSFetchRequest<PlaceEntity>(entityName: "PlaceEntity")
        guard let availablePlaces = try? context.fetch(placeRequest), !availablePlaces.isEmpty else {
            print("Cannot create trips. No Basic places in database.")
            return
        }
        
        let sampleTrips: [(name: String, placeNames: [String])] = [
            (
                name: "From Zelená Hora to Sněžka",
                placeNames: ["Pražský hrad", "Karlštejn", "Lomy Amerika", "Národní muzeum"]
            ),
            (
                name: "From Varšava to Macocha",
                placeNames: ["Café Louvré", "Karlštejn", "Lomy Amerika"]
            ),
            (
                name: "Weekend Exploration",
                placeNames: ["Národní muzeum", "Café Louvré"]
            )
        ]
        
        for tripData in sampleTrips {
            let tripEntity = TripEntity(context: context)
            tripEntity.id = UUID()
            tripEntity.name = tripData.name
            
            var currentIndex: Int16 = 0
            for name in tripData.placeNames {
                if let matchedPlaceEntity = availablePlaces.first(where: { $0.name == name }) {
                    let stopEntity = TripStopEntity(context: context)
                    stopEntity.id = UUID()
                    stopEntity.index = currentIndex
                    stopEntity.trip = tripEntity
                    stopEntity.place = matchedPlaceEntity
                    
                    currentIndex += 1
                }
            }
        }
        
        save()
        print("Trip seeding complete.")
    }*/
    
}



// MARK: User
extension CoreDataManager {
    func fetchUser() -> User {
        let request = NSFetchRequest<UserEntity>(entityName: "UserEntity")
        if let entity = try? context.fetch(request).first {
            return User(id: entity.id ?? UUID(), xp: Int(entity.xp))
        }
        let entity = UserEntity(context: context)
        entity.id = UUID()
        entity.xp = 0
        save()
        return User(id: entity.id ?? UUID(), xp: 0)
    }

    func saveUser(_ user: User) {
        let request = NSFetchRequest<UserEntity>(entityName: "UserEntity")
        let entity = (try? context.fetch(request).first) ?? UserEntity(context: context)
        entity.id = user.id
        entity.xp = Int16(user.xp)
        save()
    }
}
