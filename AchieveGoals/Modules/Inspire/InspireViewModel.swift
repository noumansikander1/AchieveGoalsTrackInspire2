import Foundation
import SwiftUI
import SwiftData
internal import Combine

@MainActor
class InspireViewModel: ObservableObject {
    @Published var quotes: [Quote] = []
    @Published var dailyQuote: Quote?
    @Published var selectedCategory = "All"
    
    private var modelContext: ModelContext?
    
    let categories = ["All", "Motivation", "Success", "Happiness", "Wisdom", "Life"]

    let defaultQuotes = [
        ("Dreams don't work unless you do.", "Unknown", "Motivation"),
        ("Success is the sum of small efforts, repeated day in and day out.", "Robert Collier", "Success"),
        ("Happiness is not in always doing what you want, but in wanting what you do.", "Leo Tolstoy", "Happiness"),
        ("A journey of a thousand miles begins with a single step.", "Lao Tzu", "Wisdom"),
        ("Life is what happens when you're busy making other plans.", "John Lennon", "Life"),
        ("The only way to do great work is to love what you do.", "Steve Jobs", "Motivation"),
        ("Don't be afraid to give up the good to go for the great.", "John D. Rockefeller", "Success"),
        ("Happiness is when what you think, what you say, and what you do are in harmony.", "Mahatma Gandhi", "Happiness"),
        ("Knowledge is treasure, but practice is the key to it.", "Thomas Fuller", "Wisdom"),
        ("Life is measured not by the number of breaths we take, but by the moments that take our breath away.", "Maya Angelou", "Life")
    ]

    
    func setup(context: ModelContext) {
        self.modelContext = context
        fetchQuotes()
        if quotes.isEmpty {
            loadDefaultQuotes()
        }
        selectDailyQuote()
    }
    
    var filteredQuotes: [Quote] {
        if selectedCategory == "All" {
            return quotes.sorted { $0.createdAt > $1.createdAt }
        }
        return quotes.filter { $0.category == selectedCategory }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    func fetchQuotes() {
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<Quote>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        do {
            quotes = try context.fetch(descriptor)
        } catch {
            print("Ошибка загрузки цитат: \(error)")
        }
    }
    
    func loadDefaultQuotes() {
        guard let context = modelContext else { return }
        
        for (text, author, category) in defaultQuotes {
            let quote = Quote(text: text, author: author, category: category)
            context.insert(quote)
        }
        
        do {
            try context.save()
            fetchQuotes()
        } catch {
            print("Ошибка загрузки дефолтных цитат: \(error)")
        }
    }
    
    func selectDailyQuote() {
        guard !quotes.isEmpty else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: today) ?? 0
        let index = dayOfYear % quotes.count
        dailyQuote = quotes[index]
    }
    
    func toggleFavorite(quote: Quote) {
        quote.toggleFavorite()
        saveContext()
    }
    
    func addQuote(text: String, author: String, category: String) {
        guard let context = modelContext else { return }
        
        let newQuote = Quote(text: text, author: author, category: category)
        context.insert(newQuote)
        
        do {
            try context.save()
            fetchQuotes()
        } catch {
            print("Ошибка сохранения цитаты: \(error)")
        }
    }
    
    func deleteQuote(quote: Quote) {
        guard let context = modelContext else { return }
        context.delete(quote)
        saveContext()
        fetchQuotes()
    }
    
    private func saveContext() {
        guard let context = modelContext else { return }
        do {
            try context.save()
            fetchQuotes()
        } catch {
            print("Ошибка сохранения: \(error)")
        }
    }
}

