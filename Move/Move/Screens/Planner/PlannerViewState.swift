//
//  PlannerViewState.swift
//  Move
//
//  Created by David Řihák on 13.06.2026.
//

import SwiftUI

@Observable
final class PlannerViewState {
    var trips: [Trip] = []
    var isAddTripPresented: Bool = false
    var selectedTrip: Trip? = nil
}
