//
//  AdditionalPlaceDetailViewState.swift
//  Move
//
//  Created by David Řihák on 14.06.2026.
//
import SwiftUI

@Observable
final class AdditionalPlaceDetailViewState {
    var additionalPlace: AdditionalPlace
    
    var isLoading = false
    var errorMessage: String? = nil
    var isShowingAIWarning = false
    
    init(additionalPlace: AdditionalPlace) {
        self.additionalPlace = additionalPlace
    }
}
