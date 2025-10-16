import Foundation
import SwiftData

@Model
final class Step {
    var id: UUID
    var title: String
    var stepDescription: String
    var isCompleted: Bool
    var createdAt: Date
    var completedAt: Date?
    var order: Int
    
    init(
        id: UUID = UUID(),
        title: String,
        stepDescription: String = "",
        isCompleted: Bool = false,
        createdAt: Date = Date(),
        completedAt: Date? = nil,
        order: Int = 0
    ) {
        self.id = id
        self.title = title
        self.stepDescription = stepDescription
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.order = order
    }
    
    func toggle() {
        isCompleted.toggle()
        completedAt = isCompleted ? Date() : nil
    }
}

