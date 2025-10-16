import Foundation
import SwiftData

@Model
final class Goal {
    var id: UUID
    var title: String
    var goalDescription: String
    var category: String
    var targetDate: Date?
    var isCompleted: Bool
    var isFavorite: Bool
    var createdAt: Date
    var completedAt: Date?
    var progress: Double
    
    @Relationship(deleteRule: .cascade)
    var steps: [Step]?
    
    init(
        id: UUID = UUID(),
        title: String,
        goalDescription: String = "",
        category: String = "Personal",
        targetDate: Date? = nil,
        isCompleted: Bool = false,
        isFavorite: Bool = false,
        createdAt: Date = Date(),
        completedAt: Date? = nil,
        progress: Double = 0.0
    ) {
        self.id = id
        self.title = title
        self.goalDescription = goalDescription
        self.category = category
        self.targetDate = targetDate
        self.isCompleted = isCompleted
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.progress = progress
    }
    
    func updateProgress() {
        guard let steps = steps, !steps.isEmpty else {
            progress = 0
            return
        }
        let completedSteps = steps.filter { $0.isCompleted }.count
        progress = Double(completedSteps) / Double(steps.count)
    }
}

