//
//  AddPlaceViewState.swift
//  Move
//
//  Created by David Řihák on 10.06.2026.
//

import SwiftUI
import PhotosUI

@Observable
final class AddPlaceViewState {
    var isEditing: Bool = false
    var place = Place(
        id: UUID(),
        name: "",
        group: "",
        description: "",
        location: .init(latitude: 0, longitude: 0),
        type: .landmark,
        photo: nil,
        timeTo: nil,
        locationTime: 0,
        price: 0,
        visited: false,
        points: 0,
        difficulty: .custom
    )
    
    var locationTimeString: String = ""
    var priceString: String = ""
    
    var tasks: [PlaceTask] = []
    var newTaskTitle: String = ""
    var newTaskPoints: Int = 20
    
    var pickedImage: PhotosPickerItem? = nil
}
