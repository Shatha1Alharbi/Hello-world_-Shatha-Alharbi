//
//  EditGoalView.swift
//  Hello world_ Shatha Alharbi
//
//  Created by Shatha Alharbi on 10/11/2026.
//

import SwiftUI

struct EditGoalView: View {

    // MARK: - Properties

    var viewModel: LearningViewModel

    @Environment(\.dismiss) private var dismiss

    @State private var goalName: String
    @State private var selectedDuration: GoalDuration
    @State private var showUpdateAlert = false

    // MARK: - Initializer

    init(viewModel: LearningViewModel) {
        self.viewModel = viewModel

        _goalName = State(
            initialValue: viewModel.currentGoal?.goalName ?? ""
        )

        _selectedDuration = State(
            initialValue: viewModel.currentGoal?.duration ?? .week
        )
    }

    // MARK: - Validation

    private var isGoalValid: Bool {
        !goalName.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty
    }

    // MARK: - View

    var body: some View {
        ZStack {
            Color("AppBackground")
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                // MARK: Goal Input

                VStack(alignment: .leading, spacing: 8) {
                    Text("I want to learn")
                        .font(.system(size: 16))
                    TextField("Swift", text: $goalName)
                        .font(.system(size: 16))
                        .foregroundStyle(.primary)
                        .tint(Color("D_Orange"))
                        .textFieldStyle(.plain)
                        .textInputAutocapitalization(.sentences)
                        .padding(.vertical, 12)

                    Rectangle()
                        .fill(Color.gray.opacity(0.45))
                        .frame(height: 1)                }
                .padding(.top, 32)

                // MARK: Duration Selection

                VStack(alignment: .leading, spacing: 13) {
                    Text("I want to learn it in a")
                        .font(.system(size: 16))

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

                Spacer()
            }
            .padding(.horizontal, 20)
        }

        // MARK: Navigation

        .navigationTitle("Learning Goal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showUpdateAlert = true
                } label: {
                    Image(systemName: "checkmark")
                        .fontWeight(.semibold)
                }
                .buttonStyle(.glassProminent)
                .tint(Color("D_Orange"))
                .disabled(!isGoalValid)
            }
        }

        // MARK: Update Confirmation

        .alert(
            "Update goal?",
            isPresented: $showUpdateAlert
        ) {
            Button("Dismiss", role: .cancel) {}

            Button("Update") {
                viewModel.updateGoal(
                    goalName: goalName.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ),
                    duration: selectedDuration
                )

                dismiss()
            }
        } message: {
            Text(
                "If you update now, your streak will start over."
            )
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        EditGoalView(viewModel: LearningViewModel())
    }
}
