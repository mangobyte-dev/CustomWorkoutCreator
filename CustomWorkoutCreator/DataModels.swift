//
//  DataModels.swift
//  CustomWorkoutCreator
//
//  Created by Developer on 16/07/2025.
//

import Foundation

struct Workout {
    var dateAndTime: Date
    var totalDuration: String
    var intervals: [Interval]
}

struct Interval {
    var excersises: [Excersise]
    var rounds: Int
}

struct Excersise {
    var title: String
    var reps: Int
    var duration: Int
    var effort: Int
    var repInstruction: String
    var rest: Int
}
