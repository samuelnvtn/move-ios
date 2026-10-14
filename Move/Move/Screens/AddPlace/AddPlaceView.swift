//
//  AddPlaceView.swift
//  Move
//
//  Created by David Řihák on 10.06.2026.
//

import SwiftUI
import PhotosUI
import CoreLocation

struct AddPlaceView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AddPlaceViewModel
    private var onSave: (() -> Void)?
    private var onDelete: (() -> Void)?


    init(_ viewModel: AddPlaceViewModel, onSave: (() -> Void)? = nil, onDelete: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.onSave = onSave
        self.onDelete = onDelete
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 14) {
                    CustomSectionHeader(title: "Name")
                    
                    TextField("Enter place name", text: $viewModel.state.place.name, axis: .horizontal)
                        .keyboardType(.default)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .background(Color(.tertiarySystemGroupedBackground), in: .rect(cornerRadius: 14))
                        .tint(.green)
                    
                    CustomSectionHeader(title: "Type")
                    
                    Menu {
                        ForEach(PlaceType.allCases) { type in
                            Button {
                                viewModel.state.place.type = type
                            } label: {
                                HStack {
                                    Text(type.name.capitalized)
                                    Spacer()
                                    Image(systemName: type.sfSymbol)
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: viewModel.state.place.type.sfSymbol)
                                .font(.body)
                                .foregroundStyle(.green)
                            
                            Text(viewModel.state.place.type.name.capitalized)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.gray.opacity(0.7))
                        }
                        .font(.body)
                        .padding()
                        .background(Color(.tertiarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                    
                    CustomSectionHeader(title: "Photo")
                    
                    PhotosPicker(selection: $viewModel.state.pickedImage, matching: .images) {
                        HStack(spacing: 10) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.body)
                            
                            Text(viewModel.state.place.photo == nil ? "Select an image" : "Change image")
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Image(systemName: "plus")
                                .font(.caption)
                        }
                        .font(.body)
                        .padding()
                        .background(Color(.tertiarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                    .onChange(of: viewModel.state.pickedImage) {
                        Task {
                            if let data = try? await viewModel.state.pickedImage?.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                viewModel.state.place.photo = image
                            }
                        }
                    }
                    
                    if let photo = viewModel.state.place.photo {
                        Image(uiImage: photo)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    
                    CustomSectionHeader(title: "Description")
                    
                    TextField("Add description", text: $viewModel.state.place.description, axis: .vertical)
                        .keyboardType(.default)
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 110, alignment: .topLeading)
                        .background(Color(.tertiarySystemGroupedBackground), in: .rect(cornerRadius: 14))
                        .tint(.green)
                    
                    CustomSectionHeader(title: "Location time")
                    
                    TextField("Time spent there in minutes", text: $viewModel.state.locationTimeString, axis: .horizontal)
                        .keyboardType(.numberPad)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .background(Color(.tertiarySystemGroupedBackground), in: .rect(cornerRadius: 14))
                        .tint(.green)
                    
                    CustomSectionHeader(title: "Price")
                    
                    TextField("Estimated price", text: $viewModel.state.priceString, axis: .horizontal)
                        .keyboardType(.numberPad)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .background(Color(.tertiarySystemGroupedBackground), in: .rect(cornerRadius: 14))
                        .tint(.green)
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 22))
                
                VStack(alignment: .leading, spacing: 16) {
                    CustomSectionHeader(title: "Tasks")
                    
                    Divider()
                    
                    HStack(spacing: 12) {
                        Button {
                            viewModel.addTask()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.green)
                        }
                        
                        TextField("Add new task", text: $viewModel.state.newTaskTitle)
                            .font(.body)
                            .fontWeight(.medium)
                            .submitLabel(.done)
                            .onSubmit {
                                viewModel.addTask()
                            }
                        
                        Stepper(value: $viewModel.state.newTaskPoints, in: 5...100, step: 5) {
                            Text("\(viewModel.state.newTaskPoints) XP")
                        }
                        .labelsHidden()
                        
                        Text("\(viewModel.state.newTaskPoints) XP")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                    
                    ForEach(viewModel.state.tasks) { task in
                        HStack(spacing: 12) {
                            Button {
                                viewModel.removeTask(task)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(.red)
                            }
                            
                            Button {
                                viewModel.toggleTask(task)
                            } label: {
                                Text(task.title)
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .strikethrough(task.isCompleted)
                                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                            }
                            
                            Spacer()
                            
                            Text("\(task.points) XP")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 24))
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if viewModel.state.isEditing {
                    Button(role: .destructive) {
                        viewModel.deleteCurrentPlace()
                        onDelete?()
                        dismiss()
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        if await viewModel.save() {
                            if let onSave = onSave {
                                onSave()
                            }
                            dismiss()
                        }
                    }
                } label: {
                    Image(systemName: "checkmark")
                        .bold()
                        .foregroundStyle(.primary)
                }
            }
        }
    }
}
