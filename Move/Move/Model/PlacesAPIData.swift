//
//  PlacesData.swift
//  Move
//
//  Created by David Řihák on 09.06.2026.
//

import Foundation

struct PlacesResponse: Codable {
    let places: [PlaceAPIData]?
}

struct PlaceAPIData: Codable, Identifiable {
    let id: String
    let displayName: DisplayName
    let formattedAddress: String?
    let photos: [PlacePhoto]?
    let location: CoordinateData?

    enum CodingKeys: String, CodingKey {
        case id
        case displayName
        case formattedAddress
        case photos
        case location
    }

    var firstPhotoName: String? {
        return photos?.first?.name
    }
}

struct DisplayName: Codable {
    let text: String
}

struct PlacePhoto: Codable {
    let name: String
    let widthPx: Int
    let heightPx: Int
}

struct CoordinateData: Codable {
    let latitude: Double
    let longitude: Double
}
