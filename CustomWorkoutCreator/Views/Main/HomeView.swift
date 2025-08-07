//
//  HomeView.swift
//  CustomWorkoutCreator
//
//  Created by Developer on 16/07/2025.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            WorkoutsView()
                .navigationTitle("Workouts")
        }
    }
}

#Preview {
    HomeView()
}
