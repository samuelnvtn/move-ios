//
//  CustomHeaderSection.swift
//  Move
//
//  Created by David Řihák on 11.06.2026.
//

import SwiftUI

struct CustomSectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title.uppercased())
            .font(.footnote)
            .fontWeight(.semibold)
            .foregroundStyle(.primary)
            .padding(.leading, 4)
            .padding(.bottom, 0)
            .textCase(nil)
    }
}
