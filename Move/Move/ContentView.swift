//
//  ContentView.swift
//  Move
//
//  Created by Samuel Novotný on 09.06.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = ContentViewModel()
    @State private var showSplash = true
    @SceneStorage("selectedTab") private var selectedTabIndex = 0

    var body: some View {
        ZStack {
            if showSplash{
                SplashView()
                    .transition(.opacity)
                    .animation(.easeOut(duration: 1.5), value: showSplash)
            } else {
                TabView(selection: $selectedTabIndex){
                    Tab("Home", systemImage: "house", value: 0){
                        HomeView()
                    }
                    Tab("Places", systemImage: "mappin", value: 1){
                        MyPlacesView()
                    }
                    Tab("Map", systemImage: "map", value: 2){
                        MapView()
                    }
                    Tab("AI Planner", systemImage: "sparkle", value: 3){
                        PlannerView()
                    }

                }
                .tabViewStyle(.sidebarAdaptable)
                .accentColor(Color(red: 52/255, green: 199/255, blue: 89/255)
)

            }
            
           
        }
        .onAppear() {
            viewModel.onAppStart()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.showSplash = false
            }
        }
    }
}

#Preview {
    ContentView()
}
