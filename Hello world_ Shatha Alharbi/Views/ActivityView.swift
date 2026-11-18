//
//  ActivityView.swift
//  Hello world_ Shatha Alharbi
//
//  Created by Shatha Alharbi on 10/11/2026.
//

import SwiftUI
import Combine




struct ActivityView: View {

    // MARK: - Properties

    var viewModel: LearningViewModel

    @Environment(\.scenePhase) private var scenePhase

    @State private var currentTime = Date()

    @State private var selectedDate = Date()

    private let calendar = Calendar.current
    
    private func refreshCurrentTime() {
        let now = Date()

        let dayChanged = !calendar.isDate(
            currentTime,
            inSameDayAs: now
        )

        currentTime = now

        if dayChanged || !viewModel.canEdit(selectedDate, now: now) {
            selectedDate = now
        }
    }

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

            if calendar.isDate(date, inSameDayAs: selectedDate)

                && viewModel.canEdit(date, now: currentTime) {

                return Color("L_Orange")

            }

            return .clear

        }

    }

    private func dayTextColor(for date: Date) -> Color {

        switch viewModel.status(for: date) {

        case .learned:

            return Color("D_Orange")

        case .frozen:

            return Color("FreezeAccent")

        case nil:

            if calendar.isDate(date, inSameDayAs: selectedDate)

                && viewModel.canEdit(date, now: currentTime) {

                return .white

            }

            return .primary

        }

    }
    private let timer = Timer.publish(
        every: 60,
        on: .main,
        in: .common
    ).autoconnect()

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

        .padding(.horizontal, 13.5)

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
            refreshCurrentTime()
        }

        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                refreshCurrentTime()
            }
        }

        .onReceive(timer) { _ in
            refreshCurrentTime()
        }

    }

    // MARK: - Header

    private var activityHeader: some View {

        HStack(alignment: .center, spacing: 0) {

            // MARK: - Title and Date

            VStack(alignment: .leading, spacing: 8) {

                Text("Activity")

                    .font(.system(size: 34, weight: .bold))

                
                Text(
                    selectedDate,
                    format: .dateTime
                        .weekday(.wide)
                        .day()
                        .month(.wide)
                )


                .font(.system(size: 17, weight: .regular))                .foregroundStyle(.secondary)

            }

            Spacer()

            // MARK: - Calendar Button

            NavigationLink {

                CalendarView(viewModel: viewModel)

            } label: {

                Image(systemName: "calendar")

                    .font(.system(size: 24, weight: .medium))

                    .frame(width: 44, height: 44)

                    .foregroundStyle(.white)

                    .contentShape(Circle())

                    .glassEffect(

                        .regular.interactive(),

                        in: .circle

                    )

            }

        .buttonStyle(.plain)

        .offset(y: -4)

        Spacer()

            .frame(width: 12)

            // MARK: - Edit Button

            NavigationLink {

                EditGoalView(viewModel: viewModel)

            } label: {

                Image(systemName: "pencil.and.outline")

        .font(.system(size: 24, weight: .medium))

                    .frame(width: 44, height: 44)

                    .foregroundStyle(.white)

                    .contentShape(Circle())

                    .glassEffect(

                        .regular.interactive(),

                        in: .circle

                    )

            }

            .buttonStyle(.plain)

            .offset(y: -4)

        }.padding(.horizontal, 6.5)

    }

    // MARK: - Weekly Calendar

    private var weeklyCalendar: some View {

        HStack(spacing: 0) {

            ForEach(weekDates, id: \.self) { date in

                Button {

                    selectedDate = date

                } label: {

                    VStack(spacing: 4) {

                        Text(

                            date,

                            format: .dateTime.weekday(.narrow)

                        )

                        .font(.system(size: 12, weight: .semibold))

                        Text(date, format: .dateTime.day())

                            .font(.system(size: 18, weight: .medium))

                            .foregroundStyle(dayTextColor(for: date))

                            .frame(width: 44, height: 44)

                            .background(

                                dayColor(for: date),

                                in: Circle()

                            )

                    }

                    .frame(maxWidth: .infinity)

                } // End Button

                .buttonStyle(.plain)

                .disabled(!viewModel.canEdit(date, now: currentTime))

            } // End ForEach

        } // End HStack

        .frame(height: 66)

        .padding(.top, 20)

        .padding(.horizontal, 6.5)

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

            .frame(width: 177, height: 102)

            .glassEffect(

                .regular,

                in: .rect(

                    cornerRadius: 34,

                    style: .continuous

                )

            )

            // Freezed Days

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

            .frame(width: 177, height: 102)

            .glassEffect(

                .regular,

                in: .rect(

                    cornerRadius: 34,

                    style: .continuous

                )

            )        }

        .padding(.top, 12)

    }

    // MARK: - Active Goal Content

    private var activeGoalContent: some View {

        VStack(spacing: 0) {

            Spacer()

                .frame(height: 48)

            // MARK: - Learned Button

            Button {

                viewModel.logAsLearned(on: selectedDate)

                currentTime = Date()

                selectedDate = currentTime

            } label: {

                Text(

                    viewModel.status(for: selectedDate) == .learned

                        ? "Logged as Learned"

                        : "Log as Learned"

                )

                .font(.system(size: 16, weight: .bold))

                .foregroundStyle(.white)

                .frame(width: 272, height: 272)

                .background(

                    viewModel.status(for: selectedDate) == .learned

                        ? Color(white: 0.27)

                        : Color("D_Orange"),

                    in: Circle()

                )

                .overlay {

                    Circle()

                        .strokeBorder(

                            Color.white.opacity(0.15),

                            lineWidth: 1

                        )

                        .allowsHitTesting(false)

                }

            }

            .buttonStyle(.plain)

            .disabled(!viewModel.canLogLearned(on: selectedDate))

            .padding(.bottom, 48)

            // MARK: - Freeze Button

            Button {

                viewModel.freezeDay(on: selectedDate)

                currentTime = Date()

                selectedDate = currentTime

            } label: {

                Text(

                    viewModel.status(for: selectedDate) == .frozen

                        ? "Frozen for a day"

                        : "Freeze for a day"

                )

                .font(.system(size: 17, weight: .medium))

                .foregroundStyle(

                    viewModel.canFreeze(on: selectedDate) ? .white : .gray

                )

                .frame(width: 272, height: 46)

                .glassEffect(

                    .regular.tint(

                        viewModel.canFreeze(on: selectedDate)

                            ? Color("FreezeAccent")

                            : .gray

                    ),

                    in: .capsule

                )

            }

            .buttonStyle(.plain)

            .disabled(!viewModel.canFreeze(on: selectedDate))

            .padding(.bottom, 16)

            // Freeze Usage

            Text(

                "\(viewModel.freezesUsed) out of "

                + "\(viewModel.freezeLimit) Freezes used"

            )

            .font(.system(size: 14, weight: .regular))

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

} // End ActivityView

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
