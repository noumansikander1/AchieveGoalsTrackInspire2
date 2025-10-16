import Foundation
import SwiftData

@Model
final class ProgressRecord {
    var id: UUID
    var date: Date
    var completedGoals: Int
    var completedSteps: Int
    var totalGoals: Int
    var totalSteps: Int
    var notes: String
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        completedGoals: Int = 0,
        completedSteps: Int = 0,
        totalGoals: Int = 0,
        totalSteps: Int = 0,
        notes: String = ""
    ) {
        self.id = id
        self.date = date
        self.completedGoals = completedGoals
        self.completedSteps = completedSteps
        self.totalGoals = totalGoals
        self.totalSteps = totalSteps
        self.notes = notes
    }
    
    var completionRate: Double {
        guard totalGoals > 0 else { return 0 }
        return Double(completedGoals) / Double(totalGoals)
    }
    
    var stepsCompletionRate: Double {
        guard totalSteps > 0 else { return 0 }
        return Double(completedSteps) / Double(totalSteps)
    }
}

