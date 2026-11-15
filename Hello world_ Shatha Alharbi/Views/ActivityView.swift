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
        HStack(alignment: .top, spacing: 0) {

            // Title and Date
            VStack(alignment: .leading, spacing: 8) {
                Text("Activity")
                    .font(.system(size: 32, weight: .bold))

                Text(
                    currentTime,
                    format: .dateTime
                        .weekday(.wide)
                        .day()
                        .month(.wide)
                )
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
            }

            Spacer()

            // Calendar Button
            NavigationLink {
                CalendarView(viewModel: viewModel)
            } label: {
                Image(systemName: "calendar")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)

            Spacer()
                .frame(width: 12)

            // Edit Button
            NavigationLink {
                EditGoalView(viewModel: viewModel)
            } label: {
                Image(systemName: "pencil.and.outline")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
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
            VStack(spacing: 4) {

                Image(systemName: "flame.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 19, height: 25)
                    .foregroundStyle(Color("D_Orange"))

                Text(viewModel.dayLabel(for: viewModel.learnedDays))
                    .font(.system(size: 16, weight: .semibold))

                Text("Learned")
                    .font(.system(size: 12, weight: .regular))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 102)
            .glassEffect(
                .regular,
                in: .rect(cornerRadius: 28)
            )

            // Frozen Days
            VStack(spacing: 4) {

                Image(systemName: "snowflake")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 19, height: 25)
                    .foregroundStyle(Color("FreezeAccent"))

                Text(viewModel.dayLabel(for: viewModel.freezesUsed))
                    .font(.system(size: 16, weight: .semibold))

                Text("Freezed")
                    .font(.system(size: 12, weight: .regular))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 102)
            .glassEffect(
                .regular,
                in: .rect(cornerRadius: 28)
            )
        }
        .padding(.top, 8)
    }


    // MARK: - Active Goal Content

    private var activeGoalContent: some View {
        VStack(spacing: 0) {

            Spacer()
                .frame(height: 48)
            // MARK: - Learned Button

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
                .foregroundStyle(.white)
                .frame(width: 272, height: 272)
                .background(
                    viewModel.isTodayLearned
                        ? Color(white: 0.27)
                        : Color("D_Orange"),
                    in: Circle()
                )
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isTodayLearned)
            .padding(.bottom, 48)

            // MARK: - Freeze Button

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
                .frame(width: 272, height: 46)
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

            // MARK: - Result Icon

            Group {
                if completed {
                    Image("SuccessIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 52)
                } else {
                    Image(systemName: "xmark.seal")
                        .font(.system(size: 40))
                        .foregroundStyle(Color("D_Orange"))
                        .frame(width: 50, height: 52)
                }
            }
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
