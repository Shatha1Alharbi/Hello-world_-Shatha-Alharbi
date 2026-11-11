//
//  LearningGoal.swift
//  Hello world_ Shatha Alharbi
//
//  Created by Shatha Alharbi on 10/11/2026.
//


import Foundation

enum GoalDuration { // مده التحدي
    case week
    case month
    case year
}

struct LearningGoal {
    var goalName: String
    var duration: GoalDuration
    var startDate: Date
}
