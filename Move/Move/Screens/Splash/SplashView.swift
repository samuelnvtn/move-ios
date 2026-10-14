//
//  SplashView.swift
//  Move
//
//  Created by Samuel Novotný on 09.06.2026.
//


import SwiftUI

struct SplashView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color(red: 255/255, green: 255/255, blue: 255/255)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 8) {
                VStack(alignment: .center, spacing: 0) {
                    HStack(spacing: 0) {
                        Image("Logo")
                    }.padding(.vertical, 24)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.black)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Visit new places. Earn points. Move your body.")
                    }
                    .font(.headline)
                    .foregroundColor(.black.opacity(0.65))
                    .multilineTextAlignment(.leading)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    SplashView()
}
