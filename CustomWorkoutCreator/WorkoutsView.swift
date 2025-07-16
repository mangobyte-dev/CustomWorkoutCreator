//
//  WorkoutsView.swift
//  CustomWorkoutCreator
//
//  Created by Developer on 16/07/2025.
//

import SwiftUI

struct WorkoutsView: View {

    
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Text("list")
            }
            .navigationTitle("Workouts")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}



#Preview {
    WorkoutsView()
}
