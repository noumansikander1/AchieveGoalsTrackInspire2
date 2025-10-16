import Foundation
import SwiftUI
import SwiftData
internal import Combine

@MainActor
class StepsViewModel: ObservableObject {
    @Published var steps: [Step] = []
    @Published var todayStepsCount: Int = 0
    @Published var weeklyStepsCount: Int = 0
    @Published var searchText = ""
    
    private var modelContext: ModelContext?
    
    func setup(context: ModelContext) {
        self.modelContext = context
        fetchSteps()
        calculateStats()
    }
    
    var filteredSteps: [Step] {
        if searchText.isEmpty {
            return steps.sorted { $0.order < $1.order }
        }
        return steps.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.stepDescription.localizedCaseInsensitiveContains(searchText)
        }.sorted { $0.order < $1.order }
    }
    
    var completedSteps: [Step] {
        steps.filter { $0.isCompleted }
    }
    
    var pendingSteps: [Step] {
        steps.filter { !$0.isCompleted }
    }
    
    var completionRate: Double {
        guard !steps.isEmpty else { return 0 }
        return Double(completedSteps.count) / Double(steps.count)
    }
    
    func fetchSteps() {
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<Step>(sortBy: [SortDescriptor(\.order)])
        do {
            steps = try context.fetch(descriptor)
        } catch {
            print("Ошибка загрузки шагов: \(error)")
        }
    }
    
    func addStep(title: String, description: String) {
        guard let context = modelContext else { return }
        
        let newStep = Step(
            title: title,
            stepDescription: description,
            order: steps.count
        )
        
        context.insert(newStep)
        
        do {
            try context.save()
            fetchSteps()
            calculateStats()
        } catch {
            print("Ошибка сохранения шага: \(error)")
        }
    }
    
    func toggleStep(step: Step) {
        step.toggle()
        saveContext()
        calculateStats()
    }
    
    func deleteStep(step: Step) {
        guard let context = modelContext else { return }
        context.delete(step)
        saveContext()
        fetchSteps()
        calculateStats()
    }
    
    private func calculateStats() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: today) ?? today
        
        todayStepsCount = steps.filter { step in
            guard let completedAt = step.completedAt else { return false }
            return calendar.isDateInToday(completedAt)
        }.count
        
        weeklyStepsCount = steps.filter { step in
            guard let completedAt = step.completedAt else { return false }
            return completedAt >= weekAgo
        }.count
    }
    
    private func saveContext() {
        guard let context = modelContext else { return }
        do {
            try context.save()
            fetchSteps()
        } catch {
            print("Ошибка сохранения: \(error)")
        }
    }
}

