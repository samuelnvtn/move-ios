//
//  Place.swift
//  Move
//
//  Created by David Řihák on 10.06.2026.
//

import SwiftUI
import CoreLocation

struct Place: Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String
    var group: String
    var description: String
    var location: CLLocationCoordinate2D
    var type: PlaceType
    var photo: UIImage?
    var timeTo: Int?
    var locationTime: Int
    var price: Int
    var visited: Bool
    var points: Int
    var difficulty: PlaceDifficulty
    var visitedOn: Date?
    var googleId: String?
    
    static func == (lhs: Place, rhs: Place) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.group == rhs.group &&
        lhs.description == rhs.description &&
        lhs.type == rhs.type &&
        lhs.photo == rhs.photo &&
        lhs.visitedOn == rhs.visitedOn &&
        lhs.googleId == rhs.googleId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(group)
    }
}
    
enum PlaceType: Int16, CaseIterable, Identifiable {
    var id: Int16 { rawValue }
    
    case landmark
    case restaurant
    case hotel
    case nature
    case museum
    case castle
    case cafe
    
    var name: String {
        switch self {
        case .landmark: return "Landmark"
        case .restaurant: return "Restaurant"
        case .hotel: return "Hotel"
        case .nature: return "Nature & Parks"
        case .museum: return "Museum"
        case .castle: return "Historical Castles"
        case .cafe: return "Cafe & Bakery"
        }
    }
    
    var statsName: String {
        switch self {
        case .landmark: return "Landmark"
        case .restaurant: return "Restaurant"
        case .hotel: return "Hotel"
        case .nature: return "Nature"
        case .museum: return "Museum"
        case .castle: return "Castle"
        case .cafe: return "Cafe"
        }
    }
    
    var sfSymbol: String {
        switch self {
        case .landmark: return "mappin.and.ellipse"
        case .restaurant: return "fork.knife"
        case .hotel: return "bed.double.fill"
        case .nature: return "tree.fill"
        case .museum: return "building.columns.fill"
        case .castle: return "house.lodge.fill"
        case .cafe: return "cup.and.saucer.fill"
        }
    }
    
    var googleType: String {
        switch self {
        case .landmark: return "tourist_attraction"
        case .restaurant: return "restaurant"
        case .hotel: return "lodging"
        case .nature: return "park"
        case .museum: return "museum"
        case .castle: return "historical_landmark"
        case .cafe: return "cafe"
        }
    }
}
    
enum PlaceDifficulty: Int16, CaseIterable, Identifiable {
    var id: Int16 { rawValue }
    case easy
    case medium
    case hard
    case custom
    
    var name: String {
        switch self {
        case .easy:
            return "Easy"
        case .medium:
            return "Medium"
        case .hard:
            return "Hard"
        case .custom:
            return "Custom"
        }
    }
}
