//
//  PlaceAnnotation.swift
//  Move
//
//  Created by David Řihák on 13.06.2026.
//

import SwiftUI

struct PlaceAnnotation: View {
    let place: Place

    var body: some View {
        Image(systemName: place.type.sfSymbol)
            .font(.system(size: 14, weight: .bold))
            .padding(8)
            .foregroundStyle(place.visited ? .white : Color(.systemGray))
            .background(place.visited ? Color(red: 52/255, green: 199/255, blue: 89/255) : Color(.systemGray5))
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 3)
    }
}
