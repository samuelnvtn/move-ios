//
//  MyPlacesView.swift
//  Move
//
//  Created by David Řihák on 10.06.2026.
//
import SwiftUI

struct MyPlacesView: View {
    @State private var viewModel = MyPlacesViewModel()
    @State private var isSearchPresented = false
    @State private var isDetailPresented = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !isSearchPresented {
                    PlacesFilterSegment(
                        selected: Binding(
                            get: { viewModel.state.selectedFilter },
                            set: { viewModel.selectFilter($0) }
                        )
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                    .padding(.top, 8)
                }

                if viewModel.sortedGroupedPlaces.isEmpty {
                    VStack {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: viewModel.state.selectedFilter == .myPlaces ? "mappin.slash" : "checkmark.seal")
                                .font(.system(size: 48))
                                .foregroundStyle(.secondary)
                            Text(viewModel.state.selectedFilter == .myPlaces ? "No places to visit" : "No visited places yet")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            Text(viewModel.state.selectedFilter == .myPlaces ? "Add places you want to explore" : "Places you visit will appear here")
                                .font(.subheadline)
                                .foregroundStyle(.tertiary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.sortedGroupedPlaces, id: \.group) { section in
                            Section(header: CustomSectionHeader(title: section.group)) {
                                ForEach(section.places) { place in
                                    MyPlacesListRow(item: viewModel.makeListItem(from: place))
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            viewModel.selectPlace(place)
                                            isDetailPresented = true
                                        }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                    .background(Color(.systemGroupedBackground))
                }
            }
            .onAppear {
                viewModel.loadData()
            }
            .navigationTitle("My places")
            .navigationBarTitleDisplayMode(.automatic)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !isSearchPresented {
                        Button {
                            withAnimation(.snappy) { isSearchPresented = true }
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .sheet(isPresented: $isDetailPresented, onDismiss: { viewModel.selectPlace(nil) }) {
                if let place = viewModel.state.selectedPlace {
                    PlaceDetailView(place: place, onUpdated: { viewModel.loadData() })
                }
            }
            .background {
                if isSearchPresented {
                    Color.clear
                        .searchable(
                            text: $viewModel.state.searchText,
                            isPresented: $isSearchPresented,
                            placement: .navigationBarDrawer(displayMode: .always),
                            prompt: "Search places or cities..."
                        )
                        .onChange(of: viewModel.state.searchText) {
                            viewModel.applyFilter()
                        }
                }
            }
        }
    }
}
