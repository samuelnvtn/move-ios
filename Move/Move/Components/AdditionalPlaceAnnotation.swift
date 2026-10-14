//
//  AdditionalPlaceAnnotation.swift
//  Move
//
//  Created by David Řihák on 14.06.2026.
//

import SwiftUI

struct AdditionalPlaceAnnotation: View {
    let additionalPlace: AdditionalPlace

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(systemName: additionalPlace.type.sfSymbol)
                .font(.system(size: 13, weight: .semibold))
                .padding(8)
                .foregroundStyle(Color(.systemGray))
                .background(Color(.systemGray5))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
            
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 11))
                .foregroundStyle(Color(red: 52/255, green: 199/255, blue: 89/255))
                .background(Color.white.clipShape(Circle()))
                .offset(x: 3, y: 3)
        }
        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 3)
    }
}
