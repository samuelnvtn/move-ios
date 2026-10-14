//
//  TripSummaryViewState.swift
//  Move
//
//  Created by David Řihák on 14.06.2026.
//

import Foundation
import SwiftUI

@Observable
final class TripSummaryViewState {
    var places: [Place]
    var preferences: String = ""
    var travelMethods: String = ""
    var isGenerating: Bool = false
    var generatedTrip: Trip? = nil
    var errorMessage: String? = nil
    var isShowingError = false

    init(places: [Place]) {
        self.places = places
    }
}
