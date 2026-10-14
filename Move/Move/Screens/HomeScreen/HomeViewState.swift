//
//  HomeViewState.swift
//  Move
//
//  Created by David Řihák on 15.06.2026.
//
import SwiftUI

@Observable
final class HomeViewState {
    var user: User = User(id: UUID(), xp: 0)
    var achievements: [StatsBadge] = []
    var recommendedPlaces: [AdditionalPlace] = []
}
