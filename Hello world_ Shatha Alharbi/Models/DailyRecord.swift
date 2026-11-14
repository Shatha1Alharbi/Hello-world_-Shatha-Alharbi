//
//  DailyRecord.swift
//  Hello world_ Shatha Alharbi
//
//  Created by Shatha Alharbi on 10/11/2026.
//

import Foundation

enum DayStatus {
    case learned
    case frozen
}

struct DailyRecord {
    let date: Date
    let status: DayStatus
}
