import SwiftUI
import SwiftData

@main
struct AppMain: App {
    @StateObject private var appViewModel = AppViewModel()
    
    let modelContainer: ModelContainer = {
        let schema = Schema([
            Goal.self,
            Step.self,
            Quote.self,
            ProgressRecord.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
            WindowGroup {
                ZStack {
                    if appViewModel.isLoading {
                        LaunchSplashScreen()
                            .transition(.opacity)
                    }
                    else if appViewModel.showWebView, let url = appViewModel.webURL {
                        WebViewContainer(url: url)
                            .transition(.opacity)
                    }
                    else if appViewModel.showOfflineScreen, let url = appViewModel.webURL {
                        WebViewContainer(url: url)
                            .transition(.opacity)
                    }
                    else if appViewModel.showNativeFallback {
                        MainTabView()
                            .modelContainer(modelContainer)
                            .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.5), value: appViewModel.isLoading)
                .animation(.easeInOut(duration: 0.5), value: appViewModel.showWebView)
                .animation(.easeInOut(duration: 0.5), value: appViewModel.showOfflineScreen)
                .animation(.easeInOut(duration: 0.5), value: appViewModel.showNativeFallback)
                .task {
                    await appViewModel.initialize()
                }
            }
        }
}

// MARK: - Launch Splash Screen
struct LaunchSplashScreen: View {
    @State private var animationAmount = 0.0
    @State private var opacity = 0.0
    
    var body: some View {
        ZStack {
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DreamsView()
                .tabItem {
                    Label("Goals", systemImage: "star.fill")
                }
                .tag(0)
            
            StepsView()
                .tabItem {
                    Label("Steps", systemImage: "figure.walk")
                }
                .tag(1)
            
            InspireView()
                .tabItem {
                    Label("Inspiration", systemImage: "quote.bubble.fill")
                }
                .tag(2)
            
            ProgressScreenView()
                .tabItem {
                    Label("Progress", systemImage: "chart.bar.fill")
                }
                .tag(3)
            
            FavoritesView()
                .tabItem {
                    Label("Favourites", systemImage: "heart.fill")
                }
                .tag(4)
        }
        .accentColor(Color(hex: "#FFD700"))
    }
}

