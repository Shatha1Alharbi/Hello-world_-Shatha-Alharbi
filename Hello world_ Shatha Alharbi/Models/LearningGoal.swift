//
//  LearningGoal.swift
//  Hello world_ Shatha Alharbi
//
//  Created by Shatha Alharbi on 10/11/2026.
//


import Foundation


enum GoalDuration: String, Codable { // مده التحدي
    case week
    case month
    case year
}


struct LearningGoal: Codable {
    var id: UUID
    var goalName: String
    var duration: GoalDuration
    var startDate: Date

    init(
        goalName: String,
        duration: GoalDuration,
        startDate: Date
    ) {
        self.id = UUID()
        self.goalName = goalName
        self.duration = duration
        self.startDate = startDate
    }

    enum CodingKeys: String, CodingKey {
        case id
        case goalName
        case duration
        case startDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )

        id = try container.decodeIfPresent(
            UUID.self,
            forKey: .id
        ) ?? UUID()

        goalName = try container.decode(
            String.self,
            forKey: .goalName
        )

        duration = try container.decode(
            GoalDuration.self,
            forKey: .duration
        )

        startDate = try container.decode(
            Date.self,
            forKey: .startDate
        )
    }
}

