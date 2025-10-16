import Foundation
import SwiftUI
import SwiftData
internal import Combine

@MainActor
class FavoritesViewModel: ObservableObject {
    @Published var favoriteGoals: [Goal] = []
    @Published var favoriteQuotes: [Quote] = []
    @Published var selectedSegment = 0
    
    private var modelContext: ModelContext?
    
    func setup(context: ModelContext) {
        self.modelContext = context
        fetchFavorites()
    }
    
    func fetchFavorites() {
        guard let context = modelContext else { return }
        
        do {
            // Fetch favorite goals
            var goalsDescriptor = FetchDescriptor<Goal>(
                predicate: #Predicate { $0.isFavorite == true },
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            favoriteGoals = try context.fetch(goalsDescriptor)
            
            // Fetch favorite quotes
            var quotesDescriptor = FetchDescriptor<Quote>(
                predicate: #Predicate { $0.isFavorite == true },
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            favoriteQuotes = try context.fetch(quotesDescriptor)
        } catch {
            print("Ошибка загрузки избранного: \(error)")
        }
    }
    
    func removeFavoriteGoal(_ goal: Goal) {
        goal.isFavorite = false
        saveContext()
    }
    
    func removeFavoriteQuote(_ quote: Quote) {
        quote.isFavorite = false
        saveContext()
    }
    
    private func saveContext() {
        guard let context = modelContext else { return }
        do {
            try context.save()
            fetchFavorites()
        } catch {
            print("Ошибка сохранения: \(error)")
        }
    }
}

