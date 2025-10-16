//
//  DreamsViewModel.swift
//  Testovoe
//
//  Created by b on 14.10.2025.
//

import SwiftUI
internal import Combine
import SwiftData

class DreamsViewModel: ObservableObject {
    @Published var goals: [Goal] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: String = "All"
    
    var filteredGoals: [Goal] {
        goals.filter { goal in
            (searchText.isEmpty || goal.title.localizedCaseInsensitiveContains(searchText)) &&
            (selectedCategory == "All" || goal.category == selectedCategory)
        }
    }
    
    var categories: [String] {
        ["All", "Personal", "Work", "Study", "Health"]
    }
    
    func setup(context: ModelContext) {
        // Load data from CoreData/SwiftData
    }
    
    func addGoal(title: String, description: String, category: String, targetDate: Date?) {
        let newGoal = Goal(
            id: UUID(),
            title: title,
            goalDescription: description,
            category: category,
            targetDate: targetDate,
            isCompleted: false,
            isFavorite: false,
            progress: 0
        )
        goals.append(newGoal)
    }
    
    func toggleFavorite(goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index].isFavorite.toggle()
        }
    }
    
    func toggleCompletion(goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index].isCompleted.toggle()
        }
    }
    
    func deleteGoal(goal: Goal) {
        goals.removeAll { $0.id == goal.id }
    }
}
