//
//  ContentView.swift
//  CustomWorkoutCreator
//
//  Created by Developer on 16/07/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            WorkoutsView()
                .tabItem {
                    Label("Workouts", systemImage: "figure.run")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}

#Preview {
    ContentView()
}
