//
//  PlacesDataServicing.swift
//  Move
//
//  Created by David Řihák on 14.06.2026.
//

protocol PlacesDataServicing {
    func seedRemainingPlaces(maxPlaces: Int, amountPerTheme: Int, radiusM: Double, lat: Double?, lng: Double?) async
}

extension PlacesDataServicing {
    func seedRemainingPlaces(maxPlaces: Int, amountPerTheme: Int, radiusM: Double, lat: Double? = nil, lng: Double? = nil) async {
        await seedRemainingPlaces(maxPlaces: maxPlaces, amountPerTheme: amountPerTheme, radiusM: radiusM, lat: lat, lng: lng)
    }
}
