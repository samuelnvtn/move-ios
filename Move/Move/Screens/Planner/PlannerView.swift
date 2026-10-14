//
//  PlannerView.swift
//  Move
//
//  Created by David Řihák on 13.06.2026.
//
import SwiftUI
import MapKit

struct PlannerView: View {
    @State private var viewModel = PlannerViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.state.trips.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("No planned trips yet")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text("Pick places and use the AI Planner to create your first trip")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(viewModel.state.trips) { trip in
                                Button {
                                    viewModel.state.selectedTrip = trip
                                } label: {
                                    TripCardView(trip: trip)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        viewModel.deleteTrip(trip)
                                    } label: {
                                        Label("Delete Trip", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Planned trips")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.state.isAddTripPresented.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                viewModel.fetchTrips()
            }
            .fullScreenCover(isPresented: $viewModel.state.isAddTripPresented) {
                TripPlacePickerView(onTripSaved: {
                    viewModel.fetchTrips()
                })
            }
            .navigationDestination(isPresented: Binding(
                get: { viewModel.state.selectedTrip != nil },
                set: { if !$0 { viewModel.state.selectedTrip = nil } }
            )) {
                if let trip = viewModel.state.selectedTrip {
                    AIItineraryResultView(trip: trip, isSaved: true, onTripDeleted: {
                        viewModel.state.selectedTrip = nil
                        viewModel.fetchTrips()
                    })
                }
            }
        }
    }
}

struct TripCardView: View {
    let trip: Trip

    private var cameraPosition: MapCameraPosition {
        guard !trip.stops.isEmpty else { return .automatic }
        
        if trip.stops.count == 1 {
            let region = MKCoordinateRegion(
                center: trip.stops[0].place.location,
                span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
            )
            return MapCameraPosition.region(region)
        }
        
        let latitudes = trip.stops.map { $0.place.location.latitude }
        let longitudes = trip.stops.map { $0.place.location.longitude }
        
        guard let minLat = latitudes.min(), let maxLat = latitudes.max(),
              let minLon = longitudes.min(), let maxLon = longitudes.max() else {
            return .automatic
        }
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.3,
            longitudeDelta: (maxLon - minLon) * 1.3
        )
        
        return MapCameraPosition.region(MKCoordinateRegion(center: center, span: span))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 1) {
                Map(position: .constant(cameraPosition), interactionModes: []) {
                    ForEach(trip.stops) { stop in
                        Annotation(stop.place.name, coordinate: stop.place.location) {
                            PlaceAnnotation(place: stop.place)
                                .scaleEffect(0.8)
                        }
                    }
                }
                .safeAreaPadding(15)
                .frame(maxWidth: .infinity)
                
                TripPhotoGrid(stops: trip.stops)
                    .frame(maxWidth: .infinity)
            }
            .frame(height: 150)
            
            VStack(alignment: .leading, spacing: 10) {
                Text(trip.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 4)
                
                if !trip.stops.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(trip.stops) { stop in
                                Text(stop.place.name)
                                    .font(.footnote)
                                    .fontWeight(.light)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color(red: 0.298, green: 0.886, blue: 0.467))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                             }
                        }
                        .padding(.horizontal, 4)
                    }
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground))
        }
        .background(.white)
        .contentShape(Rectangle())
    }
}

struct TripPhotoGrid: View {
    let stops: [TripStop]
    
    var body: some View {
        Group {
            switch stops.count {
            case 0:
                placeholderView()
                
            case 1:
                singlePhotoCell(for: 0)
                
            case 2:
                HStack(spacing: 1) {
                    singlePhotoCell(for: 0)
                    singlePhotoCell(for: 1)
                }
                
            case 3:
                HStack(spacing: 1) {
                    singlePhotoCell(for: 0)
                    VStack(spacing: 1) {
                        singlePhotoCell(for: 1)
                        singlePhotoCell(for: 2)
                    }
                }
                
            default:
                HStack(spacing: 1) {
                    singlePhotoCell(for: 0)
                    VStack(spacing: 1) {
                        singlePhotoCell(for: 1)
                        singlePhotoCell(for: 2)
                    }
                }
            }
        }
    }
    
    private func singlePhotoCell(for index: Int) -> some View {
        Color.clear
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay {
                GeometryReader { geo in
                    Group {
                        if stops.indices.contains(index), let uiImage = stops[index].place.photo {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                        } else {
                            placeholderView()
                        }
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                }
            }
    }
    
    private func placeholderView() -> some View {
        Color(.systemGray5)
            .overlay {
                Image(systemName: "photo")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
    }
}
