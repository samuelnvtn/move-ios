//
//  FilterSegment.swift
//  Move
//
//  Created by David Řihák on 10.06.2026.
//

import SwiftUI

struct PlacesFilterSegment: View {

    @Binding var selected: FilterEnum

    var body: some View {

        Picker("", selection: $selected) {

            ForEach(
                FilterEnum.allCases,
                id: \.self
            ) { filter in

                Text(filter.rawValue)
                    .tag(filter)
            }
        }
        .pickerStyle(.segmented)
    }
}
