//
//  Trip.swift
//  Move
//
//  Created by David Řihák on 13.06.2026.
//

import Foundation

struct Trip: Identifiable {
    let id: UUID
    var name: String
    var city: String
    var totalDurationMinutes: Int
    var totalCost: Int
    var stops: [TripStop]
}
