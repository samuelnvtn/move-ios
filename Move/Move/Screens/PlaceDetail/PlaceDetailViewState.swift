//
//  PlaceDetailViewState.swift
//  Move
//
//  Created by David Řihák on 16.06.2026.
//

import SwiftUI

@Observable
final class PlaceDetailViewState {
    var place: Place
    var tasks: [PlaceTask] = []
    
    init(place: Place) {
        self.place = place
    }
}
