import SwiftUI
import SwiftData
import Charts

struct ProgressScreenView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = ProgressViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // Overall Progress Circle
                    overallProgressSection
                    
                    // Stats Grid
                    statsGrid
                    
                    // Weekly Chart
                    weeklyChartSection
                    
                    // Recent Progress
                    recentProgressSection
                }
                .padding(AppTheme.Spacing.md)
            }
            .background(Color(uiColor: .systemBackground))
            .navigationTitle("Progress")
            .onAppear {
                viewModel.setup(context: modelContext)
            }
            .refreshable {
                viewModel.updateTodayProgress()
            }
        }
    }
    
    private var overallProgressSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Text("Overall progress")
                .font(AppTheme.Typography.headline)
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: viewModel.overallProgress)
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "#FFD700"), Color(hex: "#FFA500")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 1.0, dampingFraction: 0.8), value: viewModel.overallProgress)
                
                VStack(spacing: 4) {
                    Text("\(Int(viewModel.overallProgress * 100))%")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#FFD700"))
                    
                    Text("Completed")
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(AppTheme.Spacing.lg)
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
    
    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppTheme.Spacing.md) {
            StatBox(
                title: "Goals",
                value: "\(viewModel.completedGoals)/\(viewModel.totalGoals)",
                icon: "star.fill",
                color: .blue
            )
            
            StatBox(
                title: "Steps",
                value: "\(viewModel.completedSteps)/\(viewModel.totalSteps)",
                icon: "figure.walk",
                color: .green
            )
            
            StatBox(
                title: "Active goals",
                value: "\(viewModel.totalGoals - viewModel.completedGoals)",
                icon: "flame.fill",
                color: .orange
            )
            
            StatBox(
                title: "Effectiveness",
                value: "\(Int(viewModel.stepsProgress * 100))%",
                icon: "chart.line.uptrend.xyaxis",
                color: Color(hex: "#FFD700")
            )
        }
    }
    
    private var weeklyChartSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Weekly statistics")
                .font(AppTheme.Typography.headline)
            
            if viewModel.weeklyProgress.isEmpty {
                Text("Insufficient data")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(AppTheme.Spacing.xl)
            } else {
                Chart(viewModel.weeklyProgress) { record in
                    BarMark(
                        x: .value("Day", record.date, unit: .day),
                        y: .value("Completed", record.completedSteps)
                    )
                    .foregroundStyle(Color(hex: "#FFD700"))
                    .cornerRadius(4)
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                    }
                }
            }
        }
        .padding(AppTheme.Spacing.md)
        .cardStyle()
    }
    
    private var recentProgressSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Recent achievements")
                .font(AppTheme.Typography.headline)
            
            if viewModel.weeklyProgress.isEmpty {
                Text("There are no achievements yet")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(.secondary)
                    .padding(AppTheme.Spacing.md)
            } else {
                ForEach(viewModel.weeklyProgress.prefix(5), id: \.id) { record in
                    ProgressRecordRow(record: record)
                }
            }
        }
        .padding(AppTheme.Spacing.md)
        .cardStyle()
    }
}

// MARK: - Stat Box
struct StatBox: View {
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
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
    }
}

// MARK: - Progress Record Row
struct ProgressRecordRow: View {
    let record: ProgressRecord
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(record.date.formatted(style: .medium))
                    .font(AppTheme.Typography.subheadline)
                    .fontWeight(.medium)
                
                Text("\(record.completedSteps) steps completed")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            CircularProgressView(progress: record.completionRate, size: 40)
        }
        .padding(.vertical, AppTheme.Spacing.xs)
    }
}

// MARK: - Circular Progress View
struct CircularProgressView: View {
    let progress: Double
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                .frame(width: size, height: size)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color(hex: "#FFD700"), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
            
            Text("\(Int(progress * 100))%")
                .font(.system(size: size * 0.3, weight: .bold))
                .foregroundColor(Color(hex: "#FFD700"))
        }
    }
}

