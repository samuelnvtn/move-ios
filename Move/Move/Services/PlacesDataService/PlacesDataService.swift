//
//  PlacesDataService.swift
//  Move
//
//  Created by David Řihák on 14.06.2026.
//

import SwiftUI
import CoreLocation

final class PlacesDataService: PlacesDataServicing {

    func seedRemainingPlaces(maxPlaces: Int, amountPerTheme: Int, radiusM: Double, lat: Double? = nil, lng: Double? = nil) async {
        let locationManager: LocationManaging = DIContainer.shared.resolve()
        let placesService: PlacesServicing = DIContainer.shared.resolve()
        let dataManager: DataManaging = DIContainer.shared.resolve()

        var finalLatitude: Double? = lat
        var finalLongitude: Double? = lng
        
        if finalLatitude == nil || finalLongitude == nil {
            var location = locationManager.getCurrentLocation()
            var locationAttempts = 0
            
            while location == nil && locationAttempts < 4 {
                locationAttempts += 1
                print("Location not available, waiting 4 seconds... Attempt \(locationAttempts)/4")
                try? await Task.sleep(for: .seconds(4))
                location = locationManager.getCurrentLocation()
            }
            
            #if targetEnvironment(simulator)
            if location == nil {
                print("Simulator fallback: using default Brno coordinates.")
                location = CLLocationCoordinate2D(latitude: 49.1951, longitude: 16.6068)
            }
            #endif

            finalLatitude = location?.latitude
            finalLongitude = location?.longitude
        }

        guard let latCoordinate = finalLatitude, let lngCoordinate = finalLongitude else {
            print("Aborting: Could not acquire valid coordinates from parameters or manager.")
            return
        }
        
        var currentPlaces = dataManager.fetchAdditionalPlaces()
        var currentCount = currentPlaces.count
        print("Database currently contains \(currentCount) AdditionalPlaces.")
        
        guard currentCount < maxPlaces else {
            print("Generation aborted: Database already reached or exceeded target quota (\(currentCount)/\(maxPlaces)).")
            return
        }
        
        let existingPlaces = dataManager.fetchPlaces()
        let existingGoogleIds = Set(existingPlaces.compactMap { $0.googleId })
        var additionalGoogleIds = Set(currentPlaces.map { $0.googleId })
        
        var totalSavedInThisRun = 0
        var missedCount = 0
        let shuffledThemes = PlaceType.allCases.shuffled()


        // MARK: stage - Initial generation phase filtering out existing duplicates
        for theme in shuffledThemes {
            currentPlaces = dataManager.fetchAdditionalPlaces()
            if currentPlaces.count >= maxPlaces { break }

            do {
                let apiPlaces = try await placesService.getPlacesByTheme(
                    lat: latCoordinate,
                    lng: lngCoordinate,
                    theme: theme.googleType,
                    radiusM: radiusM,
                    amount: amountPerTheme
                )

                for apiPlace in apiPlaces {
                    currentPlaces = dataManager.fetchAdditionalPlaces()
                    if currentPlaces.count >= maxPlaces { break }
                    
                    guard let lat = apiPlace.location?.latitude,
                          let lng = apiPlace.location?.longitude else {
                        print("Skipping \(apiPlace.displayName.text): Missing coordinates.")
                        continue
                    }

                    if existingGoogleIds.contains(apiPlace.id) || additionalGoogleIds.contains(apiPlace.id) {
                        print("Duplicate found for ID: \(apiPlace.id) (\(apiPlace.displayName.text)). Skipping.")
                        missedCount += 1
                        continue
                    }

                    var downloadedImage: UIImage? = nil
                    if let photoRef = apiPlace.firstPhotoName {
                        print("Downloading photo for: \(apiPlace.displayName.text)")
                        if let photoData = try? await placesService.getPlacePhotoData(photoRef) {
                            downloadedImage = UIImage(data: photoData)
                        }
                    }

                    let newAdditionalPlace = AdditionalPlace(
                        id: UUID(),
                        displayName: apiPlace.displayName.text,
                        formattedAddress: apiPlace.formattedAddress ?? "No description",
                        googleId: apiPlace.id,
                        location: .init(latitude: lat, longitude: lng),
                        photo: downloadedImage,
                        type: theme
                    )

                    dataManager.saveAdditionalPlace(newAdditionalPlace)
                    additionalGoogleIds.insert(apiPlace.id)
                    totalSavedInThisRun += 1
                }

            } catch {
                print("Error during main generation for theme \(theme.name): \(error.localizedDescription)")
                continue
            }
        }

        currentPlaces = dataManager.fetchAdditionalPlaces()
        currentCount = currentPlaces.count
        print("Main generation finished. Current database count: \(currentCount)/\(maxPlaces). Missed duplicates: \(missedCount)")

        // MARK: stage - Adaptive retry cycle with incrementally expanding radius
        if missedCount > 0 && currentCount < maxPlaces {
            print("Starting adaptive retry cycle to reach target quota of \(maxPlaces) places.")
            
            var currentRadius = radiusM
            let radiusIncrement = (radiusM * 0.5) / 3.0
            var fallbackAttempt = 0
            
            while dataManager.fetchAdditionalPlaces().count < maxPlaces && fallbackAttempt < 3 {
                fallbackAttempt += 1
                currentRadius += radiusIncrement
                
                let loopCurrentPlaces = dataManager.fetchAdditionalPlaces()
                let remainingToTarget = maxPlaces - loopCurrentPlaces.count
                print("Retry attempt \(fallbackAttempt)/3. Expanding search radius to \(Int(currentRadius)) meters. Remaining spots to fill: \(remainingToTarget)")
                
                var savedInThisRun = 0
                let currentAdditionalIds = Set(loopCurrentPlaces.map { $0.googleId })
                
                for theme in PlaceType.allCases.shuffled() {
                    if dataManager.fetchAdditionalPlaces().count >= maxPlaces { break }
                    
                    do {
                        let apiPlaces = try await placesService.getPlacesByTheme(
                            lat: latCoordinate,
                            lng: lngCoordinate,
                            theme: theme.googleType,
                            radiusM: currentRadius,
                            amount: amountPerTheme
                        )
                        
                        for apiPlace in apiPlaces {
                            if dataManager.fetchAdditionalPlaces().count >= maxPlaces { break }
                            
                            guard let lat = apiPlace.location?.latitude,
                                  let lng = apiPlace.location?.longitude else {
                                continue
                            }
                            
                            if existingGoogleIds.contains(apiPlace.id) || currentAdditionalIds.contains(apiPlace.id) {
                                continue
                            }
                            
                            var downloadedImage: UIImage? = nil
                            if let photoRef = apiPlace.firstPhotoName {
                                if let photoData = try? await placesService.getPlacePhotoData(photoRef) {
                                    downloadedImage = UIImage(data: photoData)
                                }
                            }
                            
                            let newAdditionalPlace = AdditionalPlace(
                                id: UUID(),
                                displayName: apiPlace.displayName.text,
                                formattedAddress: apiPlace.formattedAddress ?? "No description",
                                googleId: apiPlace.id,
                                location: .init(latitude: lat, longitude: lng),
                                photo: downloadedImage,
                                type: theme
                            )
                            
                            dataManager.saveAdditionalPlace(newAdditionalPlace)
                            savedInThisRun += 1
                            totalSavedInThisRun += 1
                        }
                        
                    } catch {
                        print("Error during retry attempt \(fallbackAttempt) for theme \(theme.name): \(error.localizedDescription)")
                        continue
                    }
                }
                
                print("Retry attempt \(fallbackAttempt) completed. Saved \(savedInThisRun) places in this iteration.")
            }
        }

        let finalCount = dataManager.fetchAdditionalPlaces().count
        print("Process complete. Final AdditionalPlaces database count: \(finalCount)/\(maxPlaces). Added \(totalSavedInThisRun) new items.")
    }
    
}
