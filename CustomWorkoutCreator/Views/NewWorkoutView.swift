import SwiftUI
import SwiftData

struct NewWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(WorkoutStore.self) private var workoutStore
    
    @State private var workoutName = ""
    @State private var intervals: [Interval] = []
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Workout Details") {
                    TextField("Workout Name", text: $workoutName)
                }
                
                Section("Intervals") {
                    if intervals.isEmpty {
                        Text("No intervals added")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach($intervals) { $interval in
                            IntervalRow(interval: $interval)
                        }
                        .onDelete { indices in
                            intervals.remove(atOffsets: indices)
                        }
                    }
                    
                    Button("Add Interval") {
                        let newInterval = Interval()
                        newInterval.name = "Interval \(intervals.count + 1)"
                        intervals.append(newInterval)
                    }
                }
            }
            .navigationTitle("New Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveWorkout()
                    }
                    .disabled(workoutName.isEmpty || intervals.isEmpty || intervals.allSatisfy { $0.exercises.isEmpty })
                }
            }
        }
    }
    
    private func saveWorkout() {
        let workout = Workout(
            name: workoutName,
            dateAndTime: Date(),
            intervals: intervals
        )
        
        // Calculate total duration (rough estimate)
        var totalSeconds = 0
        for interval in intervals {
            for _ in 1...interval.rounds {
                // Add exercise time (rough estimate based on reps/time)
                for exercise in interval.exercises {
                    switch exercise.trainingMethod {
                    case .standard(let minReps, let maxReps):
                        // Assume 3 seconds per rep average
                        totalSeconds += ((minReps + maxReps) / 2) * 3
                    case .timed(let seconds):
                        totalSeconds += seconds
                    case .restPause(let total, _, _):
                        // Assume 3 seconds per rep for rest-pause
                        totalSeconds += total * 3
                    }
                    
                    // Add rest after exercise if specified
                    if let restAfter = exercise.restAfter {
                        totalSeconds += restAfter
                    }
                }
                
                // Add rest between rounds (except after last round)
                if interval.rounds > 1 && interval.restBetweenRounds != nil {
                    totalSeconds += interval.restBetweenRounds!
                }
            }
            
            // Add rest after interval
            if let restAfter = interval.restAfterInterval {
                totalSeconds += restAfter
            }
        }
        
        workout.totalDuration = TimeInterval(totalSeconds)
        
        // Save to store
        workoutStore.addWorkout(workout)
        
        // Dismiss view
        dismiss()
    }
}

struct IntervalRow: View {
    @Binding var interval: Interval
    @State private var isExpanded = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Interval header
            HStack {
                TextField("Interval Name", text: Binding(
                    get: { interval.name ?? "" },
                    set: { interval.name = $0.isEmpty ? nil : $0 }
                ))
                .font(.headline)
                
                Spacer()
                
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    isExpanded.toggle()
                }
            }
            
            if isExpanded {
                // Rounds and rest
                HStack {
                    Label("Rounds", systemImage: "repeat")
                    Stepper(value: Binding(
                        get: { interval.rounds },
                        set: { interval.rounds = $0 }
                    ), in: 1...10) {
                        Text("\(interval.rounds)")
                    }
                }
                
                HStack {
                    Label("Rest Between Rounds", systemImage: "timer")
                    Stepper(value: Binding(
                        get: { interval.restBetweenRounds ?? 0 },
                        set: { interval.restBetweenRounds = $0 == 0 ? nil : $0 }
                    ), in: 0...300, step: 5) {
                        Text("\(interval.restBetweenRounds ?? 0)s")
                    }
                }
                
                HStack {
                    Label("Rest After Interval", systemImage: "pause.circle")
                    Stepper(value: Binding(
                        get: { interval.restAfterInterval ?? 0 },
                        set: { interval.restAfterInterval = $0 == 0 ? nil : $0 }
                    ), in: 0...300, step: 5) {
                        Text("\(interval.restAfterInterval ?? 0)s")
                    }
                }
                
                // Exercises
                VStack(alignment: .leading, spacing: 4) {
                    Text("Exercises")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    if interval.exercises.isEmpty {
                        Text("No exercises added")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach($interval.exercises) { $exercise in
                            EditableExerciseRow(exercise: $exercise)
                        }
                        .onDelete { indices in
                            interval.exercises.remove(atOffsets: indices)
                        }
                    }
                    
                    Button {
                        let newExercise = Exercise(name: "New Exercise", trainingMethod: .standard(minReps: 8, maxReps: 12))
                        interval.exercises.append(newExercise)
                    } label: {
                        Label("Add Exercise", systemImage: "plus.circle")
                            .font(.callout)
                    }
                    .padding(.top, 4)
                }
                .padding(.top, 8)
            }
        }
        .padding(.vertical, 4)
    }
}

struct EditableExerciseRow: View {
    @Binding var exercise: Exercise
    @State private var selectedMethod = 0
    
    var body: some View {
        VStack(spacing: 8) {
            // Exercise name and effort
            HStack {
                TextField("Exercise Name", text: $exercise.name)
                    .font(.callout)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text("Effort:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Stepper(value: $exercise.effort, in: 1...10) {
                        Text("\(exercise.effort)")
                            .font(.callout)
                            .fontWeight(.semibold)
                    }
                }
            }
            
            // Training method picker
            Picker("Method", selection: $selectedMethod) {
                Text("Reps").tag(0)
                Text("Timed").tag(1)
                Text("Rest-Pause").tag(2)
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedMethod) { _, newValue in
                switch newValue {
                case 0:
                    exercise.trainingMethod = .standard(minReps: 8, maxReps: 12)
                case 1:
                    exercise.trainingMethod = .timed(seconds: 30)
                case 2:
                    exercise.trainingMethod = .restPause(targetTotal: 50, minReps: 8, maxReps: 12)
                default:
                    break
                }
            }
            
            // Method-specific controls
            Group {
                switch exercise.trainingMethod {
                case .standard(let minReps, let maxReps):
                    HStack {
                        Label("Rep Range", systemImage: "number")
                            .font(.caption)
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Stepper(value: Binding(
                                get: { minReps },
                                set: { newMin in
                                    let newMax = max(newMin, maxReps)
                                    exercise.trainingMethod = .standard(minReps: newMin, maxReps: newMax)
                                }
                            ), in: 1...50) {
                                Text("\(minReps)")
                                    .frame(width: 30)
                            }
                            
                            Text("-")
                                .foregroundStyle(.secondary)
                            
                            Stepper(value: Binding(
                                get: { maxReps },
                                set: { newMax in
                                    let newMin = min(minReps, newMax)
                                    exercise.trainingMethod = .standard(minReps: newMin, maxReps: newMax)
                                }
                            ), in: 1...50) {
                                Text("\(maxReps)")
                                    .frame(width: 30)
                            }
                        }
                    }
                    
                case .timed(let seconds):
                    HStack {
                        Label("Time", systemImage: "timer")
                        Spacer()
                        Stepper(value: Binding(
                            get: { seconds },
                            set: { newValue in
                                exercise.trainingMethod = .timed(seconds: newValue)
                            }
                        ), in: 5...300, step: 5) {
                            Text("\(seconds)s")
                        }
                    }
                    
                case .restPause(let total, let minReps, let maxReps):
                    VStack(spacing: 8) {
                        HStack {
                            Label("Target Total", systemImage: "target")
                            Spacer()
                            TextField("Total", value: Binding(
                                get: { total },
                                set: { newValue in
                                    exercise.trainingMethod = .restPause(targetTotal: newValue, minReps: minReps, maxReps: maxReps)
                                }
                            ), format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 60)
                        }
                        
                        HStack {
                            Label("Rep Range", systemImage: "number")
                                .font(.caption)
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                Stepper(value: Binding(
                                    get: { minReps },
                                    set: { newMin in
                                        let newMax = max(newMin, maxReps)
                                        exercise.trainingMethod = .restPause(targetTotal: total, minReps: newMin, maxReps: newMax)
                                    }
                                ), in: 1...20) {
                                    Text("\(minReps)")
                                        .frame(width: 30)
                                }
                                
                                Text("-")
                                    .foregroundStyle(.secondary)
                                
                                Stepper(value: Binding(
                                    get: { maxReps },
                                    set: { newMax in
                                        let newMin = min(minReps, newMax)
                                        exercise.trainingMethod = .restPause(targetTotal: total, minReps: newMin, maxReps: newMax)
                                    }
                                ), in: 1...20) {
                                    Text("\(maxReps)")
                                        .frame(width: 30)
                                }
                            }
                        }
                    }
                }
            }
            .font(.callout)
        }
        .padding(.vertical, 4)
        .onAppear {
            // Set initial picker value based on training method
            switch exercise.trainingMethod {
            case .standard:
                selectedMethod = 0
            case .timed:
                selectedMethod = 1
            case .restPause:
                selectedMethod = 2
            }
        }
    }
}

#Preview {
    NewWorkoutView()
}