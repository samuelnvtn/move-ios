//
//  ClusterAnnotation.swift
//  Move
//
//  Created by David Řihák on 15.06.2026.
//

import SwiftUI

struct ClusterAnnotation: View {
    let count: Int

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 52/255, green: 199/255, blue: 89/255).opacity(0.25))
                .frame(width: 44, height: 44)
            
            Circle()
                .fill(Color(red: 52/255, green: 199/255, blue: 89/255))
                .frame(width: 32, height: 32)
                .overlay(
                    Circle()
                        .stroke(.white, lineWidth: 2)
                )
            
            Text("\(count)")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
        }
        .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
    }
}
