//
//  LocationManaging.swift
//  Move
//
//  Created by David Řihák on 11.06.2026.
//

import SwiftUI
import CoreLocation

extension Notification.Name {
    static let locationDidUpdate = Notification.Name("LocationDidUpdate")
    static let locationAuthorizationDidChange = Notification.Name("LocationAuthorizationDidChange")
}

protocol LocationManaging {
    func getCurrentLocation() -> CLLocationCoordinate2D?
    func getLocationDistrict(_ coordinates: CLLocationCoordinate2D) async -> String
    func isLocationAuthorized() -> Bool
}
