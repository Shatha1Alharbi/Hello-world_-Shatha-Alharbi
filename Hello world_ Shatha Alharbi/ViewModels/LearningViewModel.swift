//
//  LearningViewModel.swift
//  Hello world_ Shatha Alharbi
//
//  Created by Shatha Alharbi on 10/11/2026.
//

import Foundation
import Observation

@Observable
class LearningViewModel {

    // MARK: - Properties

    var currentGoal: LearningGoal?
    var dailyRecords: [DailyRecord] = []

    private let calendar = Calendar.current

    // Records belonging to the current goal only.
    private var currentGoalRecords: [DailyRecord] = []

    // MARK: - Goal Duration

    var freezeLimit: Int {
        switch currentGoal?.duration {
        case .week:
            return 2
        case .month:
            return 8
        case .year:
            return 96
        case nil:
            return 0
        }
    }

    private var goalEndDate: Date? {
        guard let goal = currentGoal else { return nil }

        let start = calendar.startOfDay(for: goal.startDate)

        switch goal.duration {
        case .week:
            return calendar.date(byAdding: .day, value: 7, to: start)
        case .month:
            return calendar.date(byAdding: .month, value: 1, to: start)
        case .year:
            return calendar.date(byAdding: .year, value: 1, to: start)
        }
    }

    // MARK: - Statistics

    var freezesUsed: Int {
        currentGoalRecords.filter {
            $0.status == .frozen
        }.count
    }

    var learnedDays: Int {
        currentGoalRecords.filter {
            $0.status == .learned
        }.count
    }

    func dayLabel(for count: Int) -> String {
        "\(count) \(count == 1 ? "day" : "days")"
    }

    // MARK: - Goal Management

    func startLearning(
        goalName: String,
        duration: GoalDuration
    ) {
        currentGoal = LearningGoal(
            goalName: goalName,
            duration: duration,
            startDate: Date()        )

        // A new goal starts with a new streak.
        currentGoalRecords = []
    }

    func updateGoal(
        goalName: String,
        duration: GoalDuration
    ) {
        startLearning(
            goalName: goalName,
            duration: duration
        )
    }

    // MARK: - Date Helpers

    private func isSameDay(_ first: Date, _ second: Date) -> Bool {
        calendar.isDate(first, inSameDayAs: second)
    }

    private func goalStatus(for date: Date) -> DayStatus? {
        currentGoalRecords.first {
            isSameDay($0.date, date)
        }?.status
    }

    // MARK: - Goal State

    func goalState(at now: Date = Date()) -> GoalState {
        guard let goal = currentGoal,
              let endDate = goalEndDate else {
            return .active
        }

        let start = calendar.startOfDay(for: goal.startDate)
        let today = calendar.startOfDay(for: now)

        var day = start

        while day < endDate && day < today {

            // Each day has 32 hours from its midnight
            // to be marked as Learned or Frozen.
            guard let deadline = calendar.date(
                byAdding: .hour,
                value: 32,
                to: day
            ) else {
                return .failed
            }

            if now > deadline && goalStatus(for: day) == nil {
                return .failed
            }

            guard let nextDay = calendar.date(
                byAdding: .day,
                value: 1,
                to: day
            ) else {
                return .failed
            }

            day = nextDay
        }

        // Wait until the goal duration has ended.
        guard now >= endDate else {
            return .active
        }

        // Allow the final day its full grace period.
        guard let finalDay = calendar.date(
            byAdding: .day,
            value: -1,
            to: endDate
        ),
        let finalDeadline = calendar.date(
            byAdding: .hour,
            value: 32,
            to: finalDay
        ) else {
            return .failed
        }

        if now <= finalDeadline &&
            goalStatus(for: finalDay) == nil {
            return .active
        }

        // Every day must be covered by Learned or Freeze.
        var checkDay = start

        while checkDay < endDate {
            guard goalStatus(for: checkDay) != nil else {
                return .failed
            }

            guard let nextDay = calendar.date(
                byAdding: .day,
                value: 1,
                to: checkDay
            ) else {
                return .failed
            }

            checkDay = nextDay
        }

        return .completed
    }

    var goalState: GoalState {
        goalState()
    }

    // MARK: - Date Validation

    func canEdit(_ date: Date, now: Date = Date()) -> Bool {
        guard let goal = currentGoal,
              let endDate = goalEndDate,
              goalState(at: now) == .active else {
            return false
        }

        let targetDay = calendar.startOfDay(for: date)
        let today = calendar.startOfDay(for: now)
        let start = calendar.startOfDay(for: goal.startDate)

        guard targetDay >= start,
              targetDay < endDate,
              targetDay <= today else {
            return false
        }

        if targetDay == today {
            return true
        }

        guard let yesterday = calendar.date(
            byAdding: .day,
            value: -1,
            to: today
        ), targetDay == yesterday,
        let deadline = calendar.date(
            byAdding: .hour,
            value: 32,
            to: targetDay
        ) else {
            return false
        }

        return now <= deadline
    }

    // MARK: - Daily Records

    func status(for date: Date) -> DayStatus? {
        dailyRecords.first {
            isSameDay($0.date, date)
        }?.status
    }

    private func saveStatus(
        _ status: DayStatus,
        for date: Date
    ) {
        let record = DailyRecord(
            date: date,
            status: status
        )

        // Update calendar history.
        if let index = dailyRecords.firstIndex(where: {
            isSameDay($0.date, date)
        }) {
            dailyRecords[index] = record
        } else {
            dailyRecords.append(record)
        }

        // Update current goal records.
        if let index = currentGoalRecords.firstIndex(where: {
            isSameDay($0.date, date)
        }) {
            currentGoalRecords[index] = record
        } else {
            currentGoalRecords.append(record)
        }
    }

    // MARK: - Learned

    func canLogLearned(on date: Date) -> Bool {
        canEdit(date)
            && goalStatus(for: date) != .learned
    }

    func logAsLearned(on date: Date = Date()) {
        guard canLogLearned(on: date) else { return }
        saveStatus(.learned, for: date)
    }

    // MARK: - Freeze

    func canFreeze(on date: Date) -> Bool {
        guard canEdit(date),
              goalStatus(for: date) != .frozen else {
            return false
        }

        // Changing Learned to Frozen consumes one Freeze.
        return freezesUsed < freezeLimit
    }

    var canFreeze: Bool {
        canFreeze(on: Date())
    }

    func freezeDay(on date: Date = Date()) {
        guard canFreeze(on: date) else { return }
        saveStatus(.frozen, for: date)
    }

    // MARK: - Today's Status

    var isTodayLogged: Bool {
        goalStatus(for: Date()) != nil
    }

    var isTodayLearned: Bool {
        goalStatus(for: Date()) == .learned
    }

    var isTodayFrozen: Bool {
        goalStatus(for: Date()) == .frozen
    }

    // MARK: - Current Streak

    var currentStreak: Int {
        guard let goal = currentGoal,
              goalState == .active else {
            return 0
        }

        let today = calendar.startOfDay(for: Date())
        let start = calendar.startOfDay(for: goal.startDate)

        var day = today

        if goalStatus(for: today) == nil {
            guard let yesterday = calendar.date(
                byAdding: .day,
                value: -1,
                to: today
            ) else {
                return 0
            }

            day = yesterday
        }

        var streak = 0

        while day >= start {
            guard goalStatus(for: day) != nil else {
                break
            }

            streak += 1

            guard let previousDay = calendar.date(
                byAdding: .day,
                value: -1,
                to: day
            ) else {
                break
            }

            day = previousDay
        }

        return streak
    }
}

