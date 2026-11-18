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

    // MARK: - Storage Keys

    private let goalKey = "savedLearningGoal"
    private let recordsKey = "savedDailyRecords"
    private let currentRecordsKey = "savedCurrentGoalRecords"
    init() {
        loadData()
    }

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
            startDate: Date()
        )

        // A new goal starts with a new streak.
        currentGoalRecords = []

        saveData()
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

        // The goal stays active until its duration ends.
        guard now >= endDate else {
            return .active
        }

        let start = calendar.startOfDay(for: goal.startDate)

        // Give the final day its full 32-hour grace period.
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

        if goalStatus(for: finalDay) == nil &&
           now <= finalDeadline {
            return .active
        }

        // Check whether every day has been logged.
        var day = start

        while day < endDate {

            if goalStatus(for: day) == nil {
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
        dailyRecords
            .filter {
                isSameDay($0.date, date)
            }
            .max {
                $0.updatedAt < $1.updatedAt
            }?
            .status
    }




    private func saveStatus(
        _ status: DayStatus,
        for date: Date
    ) {
        guard let goal = currentGoal else {
            return
        }

        let record = DailyRecord(
            goalID: goal.id,
            date: date,
            status: status,
            updatedAt: Date()
        )

        // Update calendar history.
        if let index = dailyRecords.firstIndex(where: {
            $0.goalID == goal.id &&
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

        saveData()
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
    // MARK: - Data Persistence

    private func saveData() {
        let encoder = JSONEncoder()

        if let goal = currentGoal,
           let goalData = try? encoder.encode(goal) {
            UserDefaults.standard.set(goalData, forKey: goalKey)
        } else if currentGoal == nil {
            UserDefaults.standard.removeObject(forKey: goalKey)
        }

        if let recordsData = try? encoder.encode(dailyRecords) {
            UserDefaults.standard.set(recordsData, forKey: recordsKey)
        }

        if let currentData = try? encoder.encode(currentGoalRecords) {
            UserDefaults.standard.set(currentData, forKey: currentRecordsKey)
        }
    }
    

    private func loadData() {
        let decoder = JSONDecoder()

        if let goalData = UserDefaults.standard.data(forKey: goalKey),
           let savedGoal = try? decoder.decode(
               LearningGoal.self,
               from: goalData
           ) {
            currentGoal = savedGoal
        }

        if let recordsData = UserDefaults.standard.data(forKey: recordsKey),
           let savedRecords = try? decoder.decode(
               [DailyRecord].self,
               from: recordsData
           ) {
            dailyRecords = savedRecords
        }

        if let currentData = UserDefaults.standard.data(forKey: currentRecordsKey),
           let savedCurrentRecords = try? decoder.decode(
               [DailyRecord].self,
               from: currentData
           ) {
            currentGoalRecords = savedCurrentRecords
        }

        // Migrate legacy records belonging to the current goal.
        if let goal = currentGoal {
            for index in currentGoalRecords.indices {
                if currentGoalRecords[index].goalID == nil {
                    currentGoalRecords[index].goalID = goal.id
                }
            }

            for currentRecord in currentGoalRecords {
                if let index = dailyRecords.firstIndex(where: {
                    $0.goalID == nil &&
                    isSameDay($0.date, currentRecord.date) &&
                    $0.status == currentRecord.status
                }) {
                    dailyRecords[index].goalID = goal.id
                }
            }
        }

        saveData()
    }

}

