//
//  LearningViewModel.swift
//  Hello world_ Shatha Alharbi
//
//  Created by Shatha Alharbi on 10/11/2026.
//

import Foundation

@Observable
class LearningViewModel {

    // MARK: - Properties

    var currentGoal: LearningGoal?
    var dailyRecords: [DailyRecord] = []

    // MARK: - Statistics

    var freezesUsed: Int {
        dailyRecords.filter { $0.status == .frozen }.count
    }

    var learnedDays: Int {
        dailyRecords.filter { $0.status == .learned }.count
    }

    // MARK: - Goal Management

    func startLearning(goalName: String, duration: GoalDuration) {
        currentGoal = LearningGoal(
            goalName: goalName,
            duration: duration,
            startDate: Date()
        )
    }

    // MARK: - Daily Activity

    // Save today's status or update the existing record.
    private func updateToday(status: DayStatus) {
        let today = Date()
        let calendar = Calendar.current

        if let index = dailyRecords.firstIndex(where: {
            calendar.isDate($0.date, inSameDayAs: today)
        }) {
            dailyRecords[index] = DailyRecord(
                date: today,
                status: status
            )
        } else {
            dailyRecords.append(
                DailyRecord(
                    date: today,
                    status: status
                )
            )
        }
    }

    // Mark today as Learned, even if it was Frozen.
    func logAsLearned() {
        guard !isTodayLearned else { return }

        updateToday(status: .learned)
    }

    // Mark today as Frozen, even if it was Learned.
    func freezeDay() {
        guard canFreeze else { return }

        updateToday(status: .frozen)
    }

    // MARK: - Today's Status

    var isTodayLogged: Bool {
        status(for: Date()) != nil
    }

    var isTodayLearned: Bool {
        status(for: Date()) == .learned
    }

    var isTodayFrozen: Bool {
        status(for: Date()) == .frozen
    }

    // Freeze is available unless today is already Frozen
    // or the user has reached the freeze limit.
    var canFreeze: Bool {
        !isTodayFrozen && freezesUsed < 2
    }

    // MARK: - Calendar Status

    func status(for date: Date) -> DayStatus? {
        dailyRecords.first {
            Calendar.current.isDate(
                $0.date,
                inSameDayAs: date
            )
        }?.status
    }
}
