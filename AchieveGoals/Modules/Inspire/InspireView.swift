import SwiftUI
import SwiftData

struct InspireView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = InspireViewModel()
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Daily Quote Card
                    if let dailyQuote = viewModel.dailyQuote {
                        dailyQuoteCard(quote: dailyQuote)
                            .padding(AppTheme.Spacing.md)
                    }
                    
                    // Category Filter
                    categoryScroll
                    
                    // Quotes List
                    if viewModel.filteredQuotes.isEmpty {
                        emptyState
                    } else {
                        quotesList
                    }
                }
            }
            .navigationTitle("Inspiration")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(Color(hex: "#FFD700"))
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddQuoteSheet(viewModel: viewModel)
            }
            .onAppear {
                viewModel.setup(context: modelContext)
            }
        }
    }
    
    private func dailyQuoteCard(quote: Quote) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Image(systemName: "sun.max.fill")
                    .foregroundColor(Color(hex: "#FFD700"))
                Text("Quote of the day")
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(Color(hex: "#FFD700"))
            }
            
            Text("\"\(quote.text)\"")
                .font(AppTheme.Typography.title3)
                .fontWeight(.medium)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack {
                Text("— \(quote.author)")
                    .font(AppTheme.Typography.callout)
                    .foregroundColor(.secondary)
                    .italic()
                
                Spacer()
                
                Button(action: { viewModel.toggleFavorite(quote: quote) }) {
                    Image(systemName: quote.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(quote.isFavorite ? .red : .gray)
                }
            }
        }
        .padding(AppTheme.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xl)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#FFD700").opacity(0.2), Color(hex: "#FFF8DC").opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private var categoryScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.sm) {
                ForEach(viewModel.categories, id: \.self) { category in
                    CategoryChip(
                        title: category,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        withAnimation(.spring()) {
                            viewModel.selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
        }
    }
    
    private var quotesList: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.Spacing.md) {
                ForEach(Array(viewModel.filteredQuotes.enumerated()), id: \.element.id) { index, quote in
                    QuoteCard(quote: quote, viewModel: viewModel)
                        .transition(.opacity.combined(with: .scale))
                        .animation(.spring(response: 0.3, dampingFraction: 0.8).delay(Double(index) * 0.05), value: viewModel.filteredQuotes.count)
                }
            }
            .padding(AppTheme.Spacing.md)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "quote.bubble")
                .font(.system(size: 80))
                .foregroundColor(Color(hex: "#FFD700").opacity(0.5))
            
            Text("There are no quotes")
                .font(AppTheme.Typography.title2)
                .fontWeight(.semibold)
            
            Text("Add an inspiring quote")
                .font(AppTheme.Typography.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Quote Card
struct QuoteCard: View {
    let quote: Quote
    let viewModel: InspireViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("\"\(quote.text)\"")
                .font(AppTheme.Typography.body)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack {
                Text("— \(quote.author)")
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
                
                Spacer()
                
                Label(quote.category, systemImage: "tag")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Button(action: { viewModel.toggleFavorite(quote: quote) }) {
                    HStack {
                        Image(systemName: quote.isFavorite ? "heart.fill" : "heart")
                        Text(quote.isFavorite ? "In favorites" : "Add")
                    }
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(quote.isFavorite ? .red : .blue)
                }
                
                Spacer()
                
                Button(action: { viewModel.deleteQuote(quote: quote) }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .padding(AppTheme.Spacing.md)
        .cardStyle()
    }
}

// MARK: - Add Quote Sheet
struct AddQuoteSheet: View {
    @Environment(\.dismiss) var dismiss
    let viewModel: InspireViewModel
    
    @State private var text = ""
    @State private var author = ""
    @State private var selectedCategory = "Motivation"
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Quote") {
                    TextField("Quote text", text: $text, axis: .vertical)
                        .lineLimit(3...8)
                }
                
                Section("Author") {
                    TextField("Author's name", text: $author)
                }
                
                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(viewModel.categories.filter { $0 != "All" }, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationTitle("New quote")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        viewModel.addQuote(text: text, author: author.isEmpty ? "Unknown" : author, category: selectedCategory)
                        dismiss()
                    }
                    .disabled(text.isEmpty)
                }
            }
        }
    }
}

