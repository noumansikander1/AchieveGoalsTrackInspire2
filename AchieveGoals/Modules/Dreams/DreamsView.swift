import SwiftUI
import SwiftData

struct DreamsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = DreamsViewModel()
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    searchBar
                    
                    // Category Filter
                    categoryScroll
                    
                    // Goals List
                    if viewModel.filteredGoals.isEmpty {
                        emptyState
                    } else {
                        goalsList
                    }
                }
            }
            .navigationTitle("My goals")
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
                AddGoalSheet(viewModel: viewModel)
            }
            .onAppear {
                viewModel.setup(context: modelContext)
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search targets...", text: $viewModel.searchText)
                .textFieldStyle(.plain)
        }
        .padding(AppTheme.Spacing.sm)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(AppTheme.CornerRadius.md)
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.top, AppTheme.Spacing.sm)
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
    
    private var goalsList: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.Spacing.md) {
                ForEach(Array(viewModel.filteredGoals.enumerated()), id: \.element.id) { index, goal in
                    GoalCard(goal: goal, viewModel: viewModel)
                        .transition(.opacity.combined(with: .scale))
                        .animation(.spring(response: 0.3, dampingFraction: 0.8).delay(Double(index) * 0.05), value: viewModel.filteredGoals.count)
                }
            }
            .padding(AppTheme.Spacing.md)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "star.circle")
                .font(.system(size: 80))
                .foregroundColor(Color(hex: "#FFD700").opacity(0.5))
            
            Text("There are no goals")
                .font(AppTheme.Typography.title2)
                .fontWeight(.semibold)
            
            Text("Add your first goal and start the path to your dream")
                .font(AppTheme.Typography.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.Typography.callout)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(
                    Capsule()
                        .fill(isSelected ? Color(hex: "#FFD700") : Color(uiColor: .secondarySystemBackground))
                )
                .foregroundColor(isSelected ? .black : .primary)
        }
    }
}

// MARK: - Goal Card
struct GoalCard: View {
    let goal: Goal
    let viewModel: DreamsViewModel
    
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
                
                Button(action: { viewModel.toggleFavorite(goal: goal) }) {
                    Image(systemName: goal.isFavorite ? "star.fill" : "star")
                        .foregroundColor(goal.isFavorite ? Color(hex: "#FFD700") : .gray)
                }
            }
            
            HStack {
                Label(goal.category, systemImage: "tag")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let targetDate = goal.targetDate {
                    Label(targetDate.formatted(style: .short), systemImage: "calendar")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress Bar
            if goal.progress > 0 {
                ProgressView(value: goal.progress, total: 1.0)
                    .tint(Color(hex: "#FFD700"))
            }
            
            HStack {
                Button(action: { viewModel.toggleCompletion(goal: goal) }) {
                    HStack {
                        Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "circle")
                        Text(goal.isCompleted ? "Completed" : "In the process")
                    }
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(goal.isCompleted ? .green : .blue)
                }
                
                Spacer()
                
                Button(action: { viewModel.deleteGoal(goal: goal) }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .padding(AppTheme.Spacing.md)
        .cardStyle()
    }
}

// MARK: - Add Goal Sheet
struct AddGoalSheet: View {
    @Environment(\.dismiss) var dismiss
    let viewModel: DreamsViewModel

    @State private var title = ""
    @State private var description = ""
    @State private var selectedCategory = "Personal"
    @State private var hasTargetDate = false
    @State private var targetDate = Date()

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Information") {
                    TextField("Goal Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(viewModel.categories.filter { $0 != "All" }, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Target Date") {
                    Toggle("Set a date", isOn: $hasTargetDate)

                    if hasTargetDate {
                        DatePicker("Date", selection: $targetDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        viewModel.addGoal(
                            title: title,
                            description: description,
                            category: selectedCategory,
                            targetDate: hasTargetDate ? targetDate : nil
                        )
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}
