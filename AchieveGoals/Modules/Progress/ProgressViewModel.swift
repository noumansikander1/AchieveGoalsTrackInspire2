import Foundation
import SwiftUI
import SwiftData
internal import Combine

@MainActor
class ProgressViewModel: ObservableObject {
    @Published var progressRecords: [ProgressRecord] = []
    @Published var goals: [Goal] = []
    @Published var steps: [Step] = []
    
    private var modelContext: ModelContext?
    
    func setup(context: ModelContext) {
        self.modelContext = context
        fetchAllData()
        updateTodayProgress()
    }
    
    var totalGoals: Int {
        goals.count
    }
    
    var completedGoals: Int {
        goals.filter { $0.isCompleted }.count
    }
    
    var totalSteps: Int {
        steps.count
    }
    
    var completedSteps: Int {
        steps.filter { $0.isCompleted }.count
    }
    
    var overallProgress: Double {
        guard totalGoals > 0 else { return 0 }
        return Double(completedGoals) / Double(totalGoals)
    }
    
    var stepsProgress: Double {
        guard totalSteps > 0 else { return 0 }
        return Double(completedSteps) / Double(totalSteps)
    }
    
    var weeklyProgress: [ProgressRecord] {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        return progressRecords.filter { $0.date >= weekAgo }
            .sorted { $0.date < $1.date }
    }
    
    func fetchAllData() {
        guard let context = modelContext else { return }
        
        do {
            let goalsDescriptor = FetchDescriptor<Goal>()
            goals = try context.fetch(goalsDescriptor)
            
            let stepsDescriptor = FetchDescriptor<Step>()
            steps = try context.fetch(stepsDescriptor)
            
            let recordsDescriptor = FetchDescriptor<ProgressRecord>(
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            progressRecords = try context.fetch(recordsDescriptor)
        } catch {
            print("Ошибка загрузки данных: \(error)")
        }
    }
    
    func updateTodayProgress() {
        guard let context = modelContext else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Find or create today's record
        if let todayRecord = progressRecords.first(where: { calendar.isDate($0.date, inSameDayAs: today) }) {
            // Update existing record
            todayRecord.completedGoals = completedGoals
            todayRecord.completedSteps = completedSteps
            todayRecord.totalGoals = totalGoals
            todayRecord.totalSteps = totalSteps
        } else {
            // Create new record
            let newRecord = ProgressRecord(
                date: today,
                completedGoals: completedGoals,
                completedSteps: completedSteps,
                totalGoals: totalGoals,
                totalSteps: totalSteps
            )
            context.insert(newRecord)
        }
        
        do {
            try context.save()
            fetchAllData()
        } catch {
            print("Ошибка сохранения прогресса: \(error)")
        }
    }
    
    func getProgressForDate(_ date: Date) -> ProgressRecord? {
        let calendar = Calendar.current
        return progressRecords.first { calendar.isDate($0.date, inSameDayAs: date) }
    }
}

