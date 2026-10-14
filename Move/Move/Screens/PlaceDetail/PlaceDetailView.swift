//
//  PlaceDetailView.swift
//  Move
//
//  Created by David Řihák on 10.06.2026.
//
import SwiftUI
import MapKit

struct PlaceDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: PlaceDetailViewModel
    @State private var isEditPresented = false
    @State private var isVisitConfirmPresented = false
    var onUpdated: (() -> Void)?

    init(place: Place, onUpdated: (() -> Void)? = nil) {
        self._viewModel = State(initialValue: PlaceDetailViewModel(place: place))
        self.onUpdated = onUpdated
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    imageHeroSection
                    VStack(alignment: .leading, spacing: 24) {
                        Text(viewModel.state.place.description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                        badgesSection
                        mapPreviewSection
                        tasksSection
                        visitButton
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 24)
            }
            .ignoresSafeArea(edges: .top)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                    }
                    .foregroundStyle(.primary)
                }
                if !viewModel.state.place.visited {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { isEditPresented = true } label: {
                            Image(systemName: "pencil")
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
            .navigationDestination(isPresented: $isEditPresented) {
                AddPlaceView(
                    AddPlaceViewModel(location: .init(latitude: 0, longitude: 0), place: viewModel.state.place),
                    onSave: {
                        viewModel.refreshData()
                        isEditPresented = false
                        onUpdated?()
                    },
                    onDelete: {
                        onUpdated?()
                        dismiss()
                    }
                )
                .navigationTitle("Edit Place")
            }
        }
        .presentationDetents([.fraction(0.3), .medium, .large])
        .alert("Mark as Visited?", isPresented: $isVisitConfirmPresented) {
            Button("Mark as Visited (+150 XP)") {
                withAnimation(.spring) {
                    viewModel.markAsVisited()
                    onUpdated?()
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You'll earn 150 XP for visiting this place! This action is permanent and cannot be undone.")
        }
    }

    private var imageHeroSection: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                if let uiImage = viewModel.state.place.photo {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 240)
                        .frame(width: geometry.size.width)
                        .clipped()
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 240)
                        .foregroundColor(.secondary)
                        .frame(width: geometry.size.width)
                        .background(Color(.systemGray5))
                }

                LinearGradient(
                    colors: [.clear, .black.opacity(0.75)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.state.place.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 6) {
                        Text("\(viewModel.totalXP) XP")
                        Text("•")
                        Text(viewModel.state.place.type.name.capitalized)
                        Text("•")
                        Text("\(viewModel.state.place.locationTime) min")
                        Text("•")
                        Text("\(viewModel.state.place.price) CZK")
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.8))
                }
                .padding(16)
                .frame(width: geometry.size.width, alignment: .bottomLeading)
            }
        }
        .frame(height: 240)
    }
    
    private var mapPreviewSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Location")
                .font(.headline)
                .fontWeight(.bold)
            
            Map(position: .constant(.camera(.init(centerCoordinate: viewModel.state.place.location, distance: 15000))), interactionModes: []) {
                Annotation("", coordinate: viewModel.state.place.location) {
                    PlaceAnnotation(place: viewModel.state.place)
                }
            }
            .frame(height: 130)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        }
    }
    
    private var badgesSection: some View {
        HStack(spacing: 12) {
            badgeCell(title: "Earned XP", value: "\(viewModel.state.place.points)", color: .green)
            badgeCell(title: "Difficulty", value: viewModel.state.place.difficulty.name, color: .green)
            badgeCell(title: "Progress", value: "\(viewModel.state.tasks.filter(\.isCompleted).count)/\(viewModel.state.tasks.count)", color: .green)
        }
    }

    private var tasksSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("AI Generated Tasks")
                .font(.headline)
                .fontWeight(.bold)

            VStack(spacing: 0) {
                ForEach(viewModel.state.tasks) { task in
                    Button {
                        withAnimation(.snappy) {
                            viewModel.toggleTaskCompletion(task: task)
                            onUpdated?()
                        }
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.title3)
                                .foregroundStyle(task.isCompleted ? .green : .secondary.opacity(0.5))
                            Text(task.title)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            Text("+" + String(task.points) + " XP")
                                .font(.footnote)
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if task.id != viewModel.state.tasks.last?.id {
                        Divider().padding(.leading, 50)
                    }
                }
            }
            .background(Color(.systemGray6).opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }

    private var visitButton: some View {
        Group {
            if viewModel.state.place.visited, let visitedOn = viewModel.state.place.visitedOn {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.title2)
                        .foregroundStyle(.green)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("You visited this place")
                            .font(.body)
                            .fontWeight(.bold)
                        Text(visitedOn.formatted(date: .long, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.top, 8)
            } else {
                Button {
                    isVisitConfirmPresented = true
                } label: {
                    Text("Mark as visited")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.green)
                        .clipShape(Capsule())
                }
                .padding(.top, 8)
            }
        }
    }

    private func badgeCell(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.9))
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
