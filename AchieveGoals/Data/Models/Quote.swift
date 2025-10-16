import Foundation
import SwiftData

@Model
final class Quote {
    var id: UUID
    var text: String
    var author: String
    var category: String
    var isFavorite: Bool
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        text: String,
        author: String = "Unknown",
        category: String = "Motivation",
        isFavorite: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.text = text
        self.author = author
        self.category = category
        self.isFavorite = isFavorite
        self.createdAt = createdAt
    }
    
    func toggleFavorite() {
        isFavorite.toggle()
    }
}

