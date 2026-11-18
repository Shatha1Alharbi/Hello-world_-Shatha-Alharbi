//
//  DailyRecord.swift
//  Hello world_ Shatha Alharbi
//
//  Created by Shatha Alharbi on 10/11/2026.
//

import Foundation


enum DayStatus: String, Codable {
    case learned
    case frozen
}


struct DailyRecord: Codable {
    var goalID: UUID?
    let date: Date
    let status: DayStatus
    var updatedAt: Date

    init(
        goalID: UUID? = nil,
        date: Date,
        status: DayStatus,
        updatedAt: Date = Date()
    ) {
        self.goalID = goalID
        self.date = date
        self.status = status
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case goalID
        case date
        case status
        case updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )

        goalID = try container.decodeIfPresent(
            UUID.self,
            forKey: .goalID
        )

        date = try container.decode(
            Date.self,
            forKey: .date
        )

        status = try container.decode(
            DayStatus.self,
            forKey: .status
        )

        updatedAt = try container.decodeIfPresent(
            Date.self,
            forKey: .updatedAt
        ) ?? date
    }
}
