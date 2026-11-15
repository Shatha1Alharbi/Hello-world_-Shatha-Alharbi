//
//  ActivityView.swift
//  Hello world_ Shatha Alharbi
//
//  Created by Shatha Alharbi on 10/11/2026.
//


import SwiftUI

struct ActivityView: View {

    // MARK: - Properties

    var viewModel: LearningViewModel

    @Environment(\.scenePhase) private var scenePhase
    @State private var currentTime = Date()

    private let calendar = Calendar.current

    // MARK: - Goal State

    private var goalState: GoalState {
        viewModel.goalState(at: currentTime)
    }

    // MARK: - Week Dates

    private var weekDates: [Date] {
        guard let week = calendar.dateInterval(
            of: .weekOfYear,
            for: currentTime
        ) else {
            return []
        }

        return (0..<7).compactMap { offset in
            calendar.date(
                byAdding: .day,
                value: offset,
                to: week.start
            )
        }
    }

    // MARK: - Calendar Colors

    private func dayColor(for date: Date) -> Color {
        switch viewModel.status(for: date) {
        case .learned:
            return Color("D_Orange").opacity(0.15)

        case .frozen:
            return Color("FreezeAccent").opacity(0.15)

        case nil:
            return calendar.isDate(date, inSameDayAs: currentTime)
                ? Color("L_Orange")
                : .clear
        }
    }

    private func dayTextColor(for date: Date) -> Color {
        switch viewModel.status(for: date) {
        case .learned:
            return Color("D_Orange")

        case .frozen:
            return Color("FreezeAccent")

        case nil:
            return .white
        }
    }

    // MARK: - Main View

    var body: some View {
        VStack(spacing: 0) {

            activityHeader

            weeklyCalendar

            activityStatistics

            if goalState == .active {
                activeGoalContent
            } else {
                goalResultContent
            }
        }
        .padding(.horizontal, 20)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .top
        )
        .background {
            Color("AppBackground")
                .ignoresSafeArea()
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            currentTime = Date()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                currentTime = Date()
            }
        }
    }

    // MARK: - Header

    private var activityHeader: some View {
        HStack(alignment: .top) {

            VStack(alignment: .leading, spacing: 4) {
                Text("Activity")
                    .font(.system(size: 28, weight: .bold))

                Text(
                    currentTime,
                    format: .dateTime
                        .weekday(.wide)
                        .day()
                        .month(.wide)
                )
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
            }

            Spacer()

            // Calendar Navigation
            NavigationLink {
                CalendarView(viewModel: viewModel)
            } label: {
                Image(systemName: "calendar")
                    .font(.system(size: 16))
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.glass)

            // Edit Goal Navigation
            NavigationLink {
                EditGoalView(viewModel: viewModel)
            } label: {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 16))
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.glass)
        }
    }

    // MARK: - Weekly Calendar

    private var weeklyCalendar: some View {
        HStack(spacing: 0) {

            ForEach(weekDates, id: \.self) { date in
                VStack(spacing: 6) {

                    Text(
                        date,
                        format: .dateTime.weekday(.narrow)
                    )
                    .font(.system(size: 12, weight: .semibold))

                    Text(date, format: .dateTime.day())
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(dayTextColor(for: date))
                        .frame(width: 40, height: 40)
                        .background(
                            dayColor(for: date),
                            in: Circle()
                        )
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 20)
    }

    // MARK: - Activity Statistics

    private var activityStatistics: some View {
        HStack(spacing: 12) {

            // Learned Days
            VStack(spacing: 2) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color("D_Orange"))

                Text(viewModel.dayLabel(for: viewModel.learnedDays))
                    .font(.system(size: 14, weight: .semibold))

                Text("Learned")
                    .font(.system(size: 12))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 82)
            .glassEffect(
                .regular,
                in: .rect(cornerRadius: 24)
            )

            // Frozen Days
            VStack(spacing: 2) {
                Image(systemName: "snowflake")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color("FreezeAccent"))

                Text(viewModel.dayLabel(for: viewModel.freezesUsed))
                    .font(.system(size: 14, weight: .semibold))

                Text("Frozen")
                    .font(.system(size: 12))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 82)
            .glassEffect(
                .regular,
                in: .rect(cornerRadius: 24)
            )
        }
        .padding(.top, 8)
    }

    // MARK: - Active Goal Content

    private var activeGoalContent: some View {
        VStack(spacing: 0) {

            Spacer()
                .frame(height: 48)

            // Learned Button
            Button {
                viewModel.logAsLearned()
                currentTime = Date()
            } label: {
                Text(
                    viewModel.isTodayLearned
                        ? "Logged as Learned"
                        : "Log as Learned"
                )
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 272, height: 272)
            }
            .buttonStyle(.glassProminent)
            .tint(
                viewModel.isTodayLearned
                    ? Color(white: 0.27)
                    : Color("D_Orange")
            )
            .buttonBorderShape(.circle)
            .disabled(viewModel.isTodayLearned)
            .padding(.bottom, 48)

            // Freeze Button
            Button {
                viewModel.freezeDay()
                currentTime = Date()
            } label: {
                Text(
                    viewModel.isTodayFrozen
                        ? "Frozen for a day"
                        : "Freeze for a day"
                )
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(
                    viewModel.canFreeze ? .white : .gray
                )
                .frame(width: 260, height: 44)
                .background(
                    viewModel.canFreeze
                        ? Color("FreezeAccent")
                        : Color.gray.opacity(0.2),
                    in: Capsule()
                )
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.canFreeze)
            .padding(.bottom, 16)

            // Freeze Usage
            Text(
                "\(viewModel.freezesUsed) out of "
                + "\(viewModel.freezeLimit) Freezes used"
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    // MARK: - Goal Result Content

    private var goalResultContent: some View {
        let completed = goalState == .completed

        return VStack(spacing: 0) {

            // Result Icon
            Image(
                systemName: completed
                    ? "hands.clap.fill"
                    : "xmark.seal"
            )
            .font(.system(size: 40))
            .foregroundStyle(Color("D_Orange"))
            .padding(.bottom, 16)

            // Result Title
            Text(
                completed
                    ? "Well done!"
                    : "You didn't reach your goal this time."
            )
            .font(.system(size: 14, weight: .semibold))
            .multilineTextAlignment(.center)
            .padding(.bottom, 8)

            // Result Description
            Text(
                completed
                    ? "Ready for your next goal?"
                    : "Want to set another goal?"
            )
            .font(.system(size: 13))
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)

            // Set a Goal Button
            Button {
                viewModel.currentGoal = nil
            } label: {
                Label(
                    "Set a goal",
                    systemImage: "square.and.pencil"
                )
                .font(.system(size: 14))
                .padding(.horizontal, 18)
                .frame(height: 44)
            }
            .buttonStyle(.glassProminent)
            .tint(Color("D_Orange"))
            .buttonBorderShape(.capsule)
            .padding(.top, 64)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 56)
    }
}

// MARK: - Preview

#Preview {
    let viewModel = LearningViewModel()

    viewModel.startLearning(
        goalName: "Swift",
        duration: .week
    )

    return NavigationStack {
        ActivityView(viewModel: viewModel)
    }
}
