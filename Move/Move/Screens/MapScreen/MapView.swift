//
//  MapView.swift
//  Move
//
//  Created by Samuel Novotný on 09.06.2026.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State private var viewModel = MapViewModel()
    @State private var isAddPlaceActive = false

    var body: some View {
        NavigationStack {
            Map(position: $viewModel.state.position)
            {
                UserAnnotation()
                ForEach(viewModel.state.places) { place in
                    Annotation(place.name, coordinate: place.location) {
                        PlaceAnnotation(place: place)
                            .onTapGesture { viewModel.selectPlace(place) }
                    }
                }
                
                ForEach(viewModel.state.additionalPlaces) { additionalPlace in
                    Annotation(additionalPlace.displayName, coordinate: additionalPlace.location) {
                        AdditionalPlaceAnnotation(additionalPlace: additionalPlace)
                            .onTapGesture { viewModel.selectAdditionalPlace(additionalPlace) }
                    }
                }
                
                ForEach(viewModel.state.clusters.filter { $0.count > 1 }) { cluster in
                    Annotation("", coordinate: cluster.coordinate) {
                        ClusterAnnotation(count: cluster.count)
                            .onTapGesture { viewModel.selectCluster(cluster) }
                    }
                }
            }
            .mapControls {
                if viewModel.state.isLocationAuthorized {
                    MapUserLocationButton()
                }
            }
            .onMapCameraChange(frequency: .onEnd) { context in
                viewModel.updateCenter(context.camera.centerCoordinate, span: context.region.span)
            }
            .onAppear {
                viewModel.loadPlaces()
            }
            .overlay(alignment: .center) {
                Image(systemName: "mappin")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(.red)
                    .shadow(radius: 3)
                    .offset(y: -18)
                    .allowsHitTesting(false)
            }
            .overlay(alignment: .bottom) {
                RefetchPlacesButton(isAnimating: viewModel.state.isRegenerating) {
                    viewModel.regenerateCurrentArea()
                }
                .padding(.bottom, 12)
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(isAddPlaceActive ? .hidden : .visible, for: .tabBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { isAddPlaceActive = true } label: {
                        Image(systemName: "plus")
                            .bold()
                            .foregroundStyle(.green)
                    }
                }
            }
            .navigationDestination(isPresented: $isAddPlaceActive) {
                AddPlaceView(AddPlaceViewModel(location: viewModel.state.centerCoordinate))
                    .navigationTitle("Add Place")
            }
            .sheet(item: $viewModel.state.selectedPlace) { place in
                PlaceDetailView(place: place, onUpdated: { viewModel.loadPlaces() })
            }
            .sheet(item: $viewModel.state.selectedAdditionalPlace) { additionalPlace in
                AdditionalPlaceDetailView(additionalPlace: additionalPlace, onUpdated: {
                    viewModel.loadPlaces()
                })
            }
            .sheet(item: $viewModel.state.selectedCluster) { cluster in
                clusterPlacesList(for: cluster)
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshAdditionalPlaces"))) { _ in
                viewModel.loadPlaces()
            }
        }
    }

    func clusterPlacesList(for cluster: MapClusterItem) -> some View {
        NavigationStack {
            List {
                if !cluster.places.isEmpty {
                    Section("My Places") {
                        ForEach(cluster.places) { place in
                            Button {
                                Task {
                                    await viewModel.handlePlaceSelectionFromCluster(place)
                                }
                            } label: {
                                MyPlacesListRow(item: PlaceListItem(
                                    id: place.id,
                                    title: place.name,
                                    subtitle: place.group,
                                    image: place.photo
                                ))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                if !cluster.additionalPlaces.isEmpty {
                    Section("Recommended places") {
                        ForEach(cluster.additionalPlaces) { additionalPlace in
                            Button {
                                Task {
                                    await viewModel.handleAdditionalPlaceSelectionFromCluster(additionalPlace)
                                }
                            } label: {
                                MyPlacesListRow(item: PlaceListItem(
                                    id: additionalPlace.id,
                                    title: additionalPlace.displayName,
                                    subtitle: additionalPlace.formattedAddress,
                                    image: additionalPlace.photo
                                ))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle("Places in Cluster")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { viewModel.selectCluster(nil) } label: {
                        Image(systemName: "xmark")
                    }
                    .foregroundStyle(.primary)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
