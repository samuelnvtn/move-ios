//
//  PlaceTask.swift
//  Move
//
//  Created by David Řihák on 10.06.2026.
//

import Foundation

struct PlaceTask: Identifiable, Equatable {
    var id: UUID
    var placeId: UUID
    var title: String
    var isCompleted: Bool
    var points: Int

    static func == (lhs: PlaceTask, rhs: PlaceTask) -> Bool {
        lhs.id == rhs.id && lhs.isCompleted == rhs.isCompleted
    }
}
