import SwiftUI
import SwiftData

struct StepsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = StepsViewModel()
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Stats Cards
                    statsSection
                    
                    // Search Bar
                    searchBar
                    
                    // Steps List
                    if viewModel.filteredSteps.isEmpty {
                        emptyState
                    } else {
                        stepsList
                    }
                }
            }
            .navigationTitle("Steps")
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
                AddStepSheet(viewModel: viewModel)
            }
            .onAppear {
                viewModel.setup(context: modelContext)
            }
        }
    }
    
    private var statsSection: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            StatCard(
                title: "Today",
                value: "\(viewModel.todayStepsCount)",
                icon: "checkmark.circle.fill",
                color: .green
            )
            
            StatCard(
                title: "A week",
                value: "\(viewModel.weeklyStepsCount)",
                icon: "calendar",
                color: .blue
            )
            
            StatCard(
                title: "Completed",
                value: "\(Int(viewModel.completionRate * 100))%",
                icon: "chart.pie.fill",
                color: Color(hex: "#FFD700")
            )
        }
        .padding(AppTheme.Spacing.md)
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search for steps...", text: $viewModel.searchText)
                .textFieldStyle(.plain)
        }
        .padding(AppTheme.Spacing.sm)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(AppTheme.CornerRadius.md)
        .padding(.horizontal, AppTheme.Spacing.md)
    }
    
    private var stepsList: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.Spacing.md) {
                ForEach(Array(viewModel.filteredSteps.enumerated()), id: \.element.id) { index, step in
                    StepCard(step: step, viewModel: viewModel)
                        .transition(.opacity.combined(with: .scale))
                        .animation(.spring(response: 0.3, dampingFraction: 0.8).delay(Double(index) * 0.05), value: viewModel.filteredSteps.count)
                }
            }
            .padding(AppTheme.Spacing.md)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "figure.walk.circle")
                .font(.system(size: 80))
                .foregroundColor(Color(hex: "#FFD700").opacity(0.5))
            
            Text("There are no steps")
                .font(AppTheme.Typography.title2)
                .fontWeight(.semibold)
            
            Text("Add the first step\nto your goal")
                .font(AppTheme.Typography.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(AppTheme.Typography.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(AppTheme.Typography.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
    }
}

// MARK: - Step Card
struct StepCard: View {
    let step: Step
    let viewModel: StepsViewModel
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Button(action: { viewModel.toggleStep(step: step) }) {
                Image(systemName: step.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(step.isCompleted ? .green : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(step.title)
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(step.isCompleted ? .secondary : .primary)
                    .strikethrough(step.isCompleted)
                
                if !step.stepDescription.isEmpty {
                    Text(step.stepDescription)
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                if let completedAt = step.completedAt {
                    Text("Completed: \(completedAt.formatted(style: .short))")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
            
            Button(action: { viewModel.deleteStep(step: step) }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding(AppTheme.Spacing.md)
        .cardStyle()
    }
}

// MARK: - Add Step Sheet
struct AddStepSheet: View {
    @Environment(\.dismiss) var dismiss
    let viewModel: StepsViewModel
    
    @State private var title = ""
    @State private var description = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Step Information") {
                    TextField("Step name", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("A new step")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        viewModel.addStep(title: title, description: description)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

