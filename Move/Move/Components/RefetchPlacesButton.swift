//
//  RefetchPlacesButton.swift
//  Move
//
//  Created by David Řihák on 16.06.2026.
//

import SwiftUI

struct RefetchPlacesButton: View {
    let isAnimating: Bool
    var action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: isAnimating ? "arrow.triangle.2.circlepath" : "sparkles")
                    .font(.system(size: 14, weight: .bold))
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                
                Text(isAnimating ? "Searching..." : "Regenerate Area")
                    .font(.footnote)
                    .fontWeight(.bold)
            }
            .foregroundStyle(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(Color(red: 52/255, green: 199/255, blue: 89/255))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color(red: 52/255, green: 199/255, blue: 89/255).opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .disabled(isAnimating)
    }
}
