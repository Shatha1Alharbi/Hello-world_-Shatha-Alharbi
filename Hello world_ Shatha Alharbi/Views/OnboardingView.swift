//
//  OnboardingView.swift
//  Hello world_ Shatha Alharbi
//
//  Created by Shatha Alharbi on 10/11/2026.
//

import SwiftUI

struct OnboardingView: View {

    @State private var goalName = ""
    @State private var selectedDuration: GoalDuration = .week

    var viewModel: LearningViewModel

    var body: some View {

        ZStack {

            Color("AppBackground")
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                // MARK: - Flame

                Image(systemName: "flame.fill")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(Color("D_Orange"))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 57)

                // MARK: - Welcome Section

                VStack(alignment: .leading, spacing: 4) {

                    Text("Hello \(Text("Learner").bold())")
                        .font(.system(size: 34))

                    Text("This app will help you learn everyday!")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 80)

                // MARK: - Goal Input

                VStack(alignment: .leading, spacing: 5) {

                    Text("I want to learn")
                        .font(.system(size: 16, weight: .regular))

                    TextField("Swift", text: $goalName)
                        .font(.system(size: 16))
                        .frame(height: 48)

                    Divider()
                }
                .padding(.top, 37)

                // MARK: - Duration Selection

                VStack(alignment: .leading, spacing: 13) {

                    Text("I want to learn it in a")
                        .font(.system(size: 16, weight: .regular))

                    HStack(spacing: 12) {

                        DurationButton(
                            title: "Week",
                            duration: .week,
                            selectedDuration: $selectedDuration
                        )

                        DurationButton(
                            title: "Month",
                            duration: .month,
                            selectedDuration: $selectedDuration
                        )

                        DurationButton(
                            title: "Year",
                            duration: .year,
                            selectedDuration: $selectedDuration
                        )
                    }
                }
                .padding(.top, 30)

                Spacer(minLength: 0)

                // MARK: - Start Learning Button

                Button {

                    viewModel.startLearning(
                        goalName: goalName,
                        duration: selectedDuration
                    )

                } label: {

                    Text("Start Learning")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                    .frame(width: 130, height: 36)
                }
                .buttonStyle(.glassProminent)
                .tint(Color("D_Orange"))
                .frame(maxWidth: .infinity)
                .disabled(goalName.isEmpty)
                .padding(.bottom, 12)

                // MARK: - Footer

                Text("You can edit your desire later")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    OnboardingView(viewModel: LearningViewModel())
}
