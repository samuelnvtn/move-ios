//
//  TripStop.swift
//  Move
//
//  Created by David Řihák on 13.06.2026.
//

import Foundation

struct TravelLeg: Identifiable, Codable {
    let id: UUID
    let mode: String
    let info: String
}

struct TripStop: Identifiable {
    let id: UUID
    var index: Int
    var place: Place
    var note: String
    var travelLegs: [TravelLeg]
    var travelMinutes: Int
    var travelCost: Int
}
