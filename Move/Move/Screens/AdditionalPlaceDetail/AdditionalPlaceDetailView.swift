//
//  AdditionalPlaceDetailView.swift
//  Move
//
//  Created by David Řihák on 14.06.2026.
//

import SwiftUI
import MapKit

struct AdditionalPlaceDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AdditionalPlaceDetailViewModel
    var onUpdated: (() -> Void)?

    init(additionalPlace: AdditionalPlace, onUpdated: (() -> Void)? = nil) {
        self._viewModel = State(initialValue: AdditionalPlaceDetailViewModel(additionalPlace: additionalPlace))
        self.onUpdated = onUpdated
    }

    var body: some View {
        @Bindable var vmState = viewModel.state
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    imageHeroSection
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text(viewModel.state.additionalPlace.formattedAddress)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                        
                        Spacer().frame(height: 12)
                        
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
                    .disabled(viewModel.state.isLoading)
                }
            }
        }
        .presentationDetents([.medium])
        .interactiveDismissDisabled(viewModel.state.isLoading)
        .alert("Place Saved", isPresented: $vmState.isShowingAIWarning) {
            Button("OK") {
                onUpdated?()
                dismiss()
            }
        } message: {
            Text("The place was saved, but AI couldn't be reached. Tasks, visit time, and difficulty may be missing.")
        }
    }

    private var imageHeroSection: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                if let uiImage = viewModel.state.additionalPlace.photo {
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
                    Text(viewModel.state.additionalPlace.displayName)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 6) {
                        Text("?? XP")
                        Text("•")
                        Text(viewModel.state.additionalPlace.type.name.capitalized)
                        Text("•")
                        Text("?? Min")
                        Text("•")
                        Text("?? CZK")
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

    private var visitButton: some View {
        Button {
            Task {
                let success = await viewModel.addAdditionalPlace()
                if success && !viewModel.state.isShowingAIWarning {
                    onUpdated?()
                    dismiss()
                }
            }
        } label: {
            Group {
                if viewModel.state.isLoading {
                    HStack(spacing: 8) {
                        ProgressView()
                            .tint(.white)
                        Text("Generating tasks...")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        Image(systemName: "sparkles")
                            .foregroundStyle(.white)
                    }
                } else {
                    Text("Add to My Places")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(viewModel.state.isLoading ? Color.green.opacity(0.7) : Color.green)
            .clipShape(Capsule())
        }
        .disabled(viewModel.state.isLoading)
        .padding(.top, 8)
    }
}
