import SwiftUI

@main struct MyApp: App {
    @State private var viewModel = LearningViewModel()
    var body: some Scene {
        WindowGroup {
            if viewModel.currentGoal == nil {
                OnboardingView(viewModel: viewModel)
            } else {
                ActivityView(viewModel: viewModel)
            }

        }
    }
}
