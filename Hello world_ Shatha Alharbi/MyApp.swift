
import SwiftUI

@main
struct MyApp: App {

    // MARK: - Shared ViewModel

    @State private var viewModel = LearningViewModel()

    // MARK: - App Scene

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if viewModel.currentGoal == nil {
                    OnboardingView(viewModel: viewModel)
                } else {
                    ActivityView(viewModel: viewModel)
                }
            }
        }
    }
}
