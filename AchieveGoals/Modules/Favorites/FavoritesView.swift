import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = FavoritesViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segment Control
                Picker("Type", selection: $viewModel.selectedSegment) {
                    Text("Goals (\(viewModel.favoriteGoals.count))").tag(0)
                    Text("Quotes (\(viewModel.favoriteQuotes.count))").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(AppTheme.Spacing.md)
                
                // Content
                if viewModel.selectedSegment == 0 {
                    favoriteGoalsView
                } else {
                    favoriteQuotesView
                }
            }
            .background(Color(uiColor: .systemBackground))
            .navigationTitle("Favorites")
            .onAppear {
                viewModel.setup(context: modelContext)
            }
            .refreshable {
                viewModel.fetchFavorites()
            }
        }
    }
    
    private var favoriteGoalsView: some View {
        Group {
            if viewModel.favoriteGoals.isEmpty {
                emptyState(
                    icon: "star.slash",
                    title: "No favorite goals",
                    subtitle: "Mark goals with a star\nto see them here"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: AppTheme.Spacing.md) {
                        ForEach(viewModel.favoriteGoals, id: \.id) { goal in
                            FavoriteGoalCard(goal: goal, viewModel: viewModel)
                                .transition(.opacity.combined(with: .scale))
                        }
                    }
                    .padding(AppTheme.Spacing.md)
                }
            }
        }
    }
    
    private var favoriteQuotesView: some View {
        Group {
            if viewModel.favoriteQuotes.isEmpty {
                emptyState(
                    icon: "heart.slash",
                    title: "No favorite quotes",
                    subtitle: "Add quotes to favorites\nto see them here"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: AppTheme.Spacing.md) {
                        ForEach(viewModel.favoriteQuotes, id: \.id) { quote in
                            FavoriteQuoteCard(quote: quote, viewModel: viewModel)
                                .transition(.opacity.combined(with: .scale))
                        }
                    }
                    .padding(AppTheme.Spacing.md)
                }
            }
        }
    }
    
    private func emptyState(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 80))
                .foregroundColor(Color(hex: "#FFD700").opacity(0.5))
            
            Text(title)
                .font(AppTheme.Typography.title2)
                .fontWeight(.semibold)
            
            Text(subtitle)
                .font(AppTheme.Typography.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Favorite Goal Card
struct FavoriteGoalCard: View {
    let goal: Goal
    let viewModel: FavoritesViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(.primary)
                    
                    if !goal.goalDescription.isEmpty {
                        Text(goal.goalDescription)
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                Button(action: { viewModel.removeFavoriteGoal(goal) }) {
                    Image(systemName: "star.fill")
                        .foregroundColor(Color(hex: "#FFD700"))
                }
            }
            
            HStack {
                Label(goal.category, systemImage: "tag")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if goal.isCompleted {
                    Label("Completed", systemImage: "checkmark.circle.fill")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(.green)
                }
            }
            
            if goal.progress > 0 {
                ProgressView(value: goal.progress, total: 1.0)
                    .tint(Color(hex: "#FFD700"))
            }
        }
        .padding(AppTheme.Spacing.md)
        .cardStyle()
    }
}

// MARK: - Favorite Quote Card
struct FavoriteQuoteCard: View {
    let quote: Quote
    let viewModel: FavoritesViewModel
    
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
                Text(quote.createdAt.timeAgo())
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: { viewModel.removeFavoriteQuote(quote) }) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                }
            }
        }
        .padding(AppTheme.Spacing.md)
        .cardStyle()
    }
}
