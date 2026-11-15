//
//  CalendarView.swift
//  Hello world_ Shatha Alharbi
//
//  Created by Shatha Alharbi on 10/11/2026.
//


import SwiftUI

struct CalendarView: View {

    // MARK: - Properties

    var viewModel: LearningViewModel

    private let calendar = Calendar.current

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 0),
        count: 7
    )


    // MARK: - Calendar Months

    // Display every month from January to the current month.
    // Include previous years when activity history exists.
    private var months: [Date] {
        let calendar = Calendar.current
        let today = Date()

        guard let currentYearStart = calendar.date(
            from: DateComponents(
                year: calendar.component(.year, from: today),
                month: 1,
                day: 1
            )
        ) else {
            return []
        }

        let firstRecord = viewModel.dailyRecords
            .map(\.date)
            .min()

        let startDate = min(
            currentYearStart,
            firstRecord ?? currentYearStart
        )

        guard let firstMonth = calendar.dateInterval(
            of: .month,
            for: startDate
        )?.start,
        let currentMonth = calendar.dateInterval(
            of: .month,
            for: today
        )?.start,
        let monthCount = calendar.dateComponents(
            [.month],
            from: firstMonth,
            to: currentMonth
        ).month else {
            return []
        }

        return (0...monthCount).compactMap {
            calendar.date(
                byAdding: .month,
                value: $0,
                to: firstMonth
            )
        }
    }


    // MARK: - Weekday Labels

    private let weekdays = [
        "SUN", "MON", "TUE", "WED",
        "THU", "FRI", "SAT"
    ]

    // MARK: - Month Dates

    private func dates(for month: Date) -> [Date?] {
        guard let range = calendar.range(
            of: .day,
            in: .month,
            for: month
        ),
        let firstDay = calendar.dateInterval(
            of: .month,
            for: month
        )?.start else {
            return []
        }

        // Convert weekday to Sunday-based column index.
        let leadingDays = (
            calendar.component(.weekday, from: firstDay) + 6
        ) % 7

        let emptyCells = Array<Date?>(
            repeating: nil,
            count: leadingDays
        )

        let monthDays: [Date?] = range.compactMap {
            calendar.date(
                byAdding: .day,
                value: $0 - 1,
                to: firstDay
            )
        }

        return emptyCells + monthDays
    }


    // MARK: - Day Colors

    private func dayBackground(for date: Date) -> Color {
        switch viewModel.status(for: date) {
        case .learned:
            return Color("D_Orange").opacity(0.15)

        case .frozen:
            return Color("FreezeAccent").opacity(0.15)

        case nil:
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
            return .white
        }
    }

    // MARK: - Day Cell


    // MARK: - Day Cell

    private func dayCell(for date: Date) -> some View {
        Text(date, format: .dateTime.day())
            .font(.system(size: 20, weight: .bold))
            .foregroundStyle(dayTextColor(for: date))
            .frame(width: 38, height: 38)
            .background(
                dayBackground(for: date),
                in: Circle()
            )
            .frame(maxWidth: .infinity)
            .frame(height: 46)
    }

    // MARK: - Month Section

    private func monthSection(_ month: Date) -> some View {
        VStack(alignment: .leading, spacing: 10) {

            // Month Title
            Text(
                month,
                format: .dateTime.month(.wide).year()
            )
            .font(.system(size: 16, weight: .semibold))

            // Weekday Headers
            LazyVGrid(columns: columns, spacing: 0) {

                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 28)
                }

                // Calendar Days
                ForEach(
                    Array(dates(for: month).enumerated()),
                    id: \.offset
                ) { _, date in

                    if let date {
                        dayCell(for: date)
                    } else {
                        Color.clear
                            .frame(height: 46)
                    }
                }
            }

            // Month Divider
            Rectangle()
                .fill(Color.gray.opacity(0.35))
                .frame(height: 1)
                .padding(.top, 4)
        }
    }


    // MARK: - View

    
    // MARK: - View

    var body: some View {
        ZStack {
            Color("AppBackground")
                .ignoresSafeArea()

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(
                        alignment: .leading,
                        spacing: 16
                    ) {
                        ForEach(months, id: \.self) { month in
                            monthSection(month)
                                .id(month)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
                .onAppear {
                    guard let currentMonth = calendar.dateInterval(
                        of: .month,
                        for: Date()
                    )?.start else {
                        return
                    }

                    proxy.scrollTo(
                        currentMonth,
                        anchor: .top
                    )
                }
            }
        }
        .navigationTitle("Activities")
        .navigationBarTitleDisplayMode(.inline)
    }
}



// MARK: - Preview

#Preview {
    NavigationStack {
        CalendarView(viewModel: LearningViewModel())
    }
}
