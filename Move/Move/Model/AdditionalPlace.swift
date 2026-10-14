//
//  AdditionalPlace.swift
//  Move
//
//  Created by David Řihák on 14.06.2026.
//

import SwiftUI
import CoreLocation

struct AdditionalPlace: Identifiable, Equatable {
    let id: UUID
    var displayName: String
    var formattedAddress: String
    var googleId: String
    var location: CLLocationCoordinate2D
    var photo: UIImage?
    var type: PlaceType

    static func == (lhs: AdditionalPlace, rhs: AdditionalPlace) -> Bool {
        lhs.id == rhs.id &&
        lhs.displayName == rhs.displayName &&
        lhs.formattedAddress == rhs.formattedAddress &&
        lhs.googleId == rhs.googleId &&
        lhs.location.latitude == rhs.location.latitude &&
        lhs.location.longitude == rhs.location.longitude &&
        lhs.photo == rhs.photo
    }
}
