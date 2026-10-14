//
//  PlaceListItem.swift
//  Move
//
//  Created by David Řihák on 10.06.2026.
//

import SwiftUI

struct PlaceListItem: Identifiable, Equatable {

    let id: UUID
    let title: String
    let subtitle: String
    let image: UIImage?

    static func == (lhs: PlaceListItem, rhs: PlaceListItem) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title && lhs.subtitle == rhs.subtitle
    }
}

struct MyPlacesListRow: View {

    let item: PlaceListItem

    var body: some View {
        HStack(spacing: 12) {
            if let image = item.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.gray.opacity(0.15))
                    .frame(width: 48, height: 48)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                Text(item.subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
        .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
    }
}
