//
//  TripPlacePickerView.swift
//  Move
//
//  Created by David Řihák on 14.06.2026.
//

import SwiftUI
import MapKit

struct TripPlacePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = TripPlacePickerViewModel()
    @State private var isSheetPresented = true
    @State private var isFormPresented = false

    var onTripSaved: () -> Void

    var body: some View {
        NavigationStack {
            Map(position: $viewModel.state.position) {
                ForEach(viewModel.state.allPlaces) { place in
                    let isSelected = viewModel.state.selectedPlaces.contains(where: { $0.id == place.id })

                    Annotation(place.name, coordinate: place.location) {
                        PlaceAnnotation(place: place)
                            .scaleEffect(isSelected ? 1.2 : 1.0)
                            .onTapGesture {
                                withAnimation(.snappy) {
                                    viewModel.handlePlaceSelection(place)
                                }
                            }
                    }
                }
            }
            .navigationTitle("Pick Places")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $isSheetPresented) {
                NavigationStack {
                    List {
                        ForEach(Array(viewModel.state.selectedPlaces.enumerated()), id: \.element.id) { index, place in
                            HStack(spacing: 3) {
                                Text("\(index + 1).")
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 25, alignment: .leading)

                                Text(place.name)
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .lineLimit(1)

                                Spacer()
                            }
                        }
                        .listRowBackground(Color(.systemGray6))
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    }
                    .listStyle(.insetGrouped)
                    .navigationTitle("Places picked: \(viewModel.state.selectedPlaces.count)")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button {
                                withAnimation(.snappy) {
                                    viewModel.state.selectedPlaces.removeAll()
                                }
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundStyle(.red)
                            }
                            .disabled(viewModel.state.selectedPlaces.isEmpty)
                        }

                        ToolbarItem(placement: .confirmationAction) {
                            Button {
                                guard !viewModel.state.selectedPlaces.isEmpty else { return }
                                isFormPresented = true
                            } label: {
                                Image(systemName: "checkmark")
                                    .font(.headline)
                                    .bold()
                                    .foregroundStyle(viewModel.state.selectedPlaces.isEmpty ? .gray : .green)
                            }
                            .disabled(viewModel.state.selectedPlaces.isEmpty)
                        }
                    }
                    .presentationDetents([.fraction(0.35), .medium, .large])
                    .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                    .interactiveDismissDisabled()
                    .fullScreenCover(isPresented: $isFormPresented) {
                        TripSummaryView(
                            places: viewModel.state.selectedPlaces,
                            onTripSaved: {
                                onTripSaved()
                                dismiss()
                            }
                        )
                    }
                }
            }
        }
    }
}
