//
//  ActivityView.swift
//  Hello world_ Shatha Alharbi
//
//  Created by Shatha Alharbi on 10/11/2026.
//


import SwiftUI

struct ActivityView: View {

    // MARK: - ViewModel

    var viewModel: LearningViewModel

    // MARK: - Week Dates

    private var weekDates: [Date] {
        let calendar = Calendar.current

        guard let week = calendar.dateInterval(
            of: .weekOfYear,
            for: Date()
        ) else {
            return []
        }

        return (0..<7).compactMap {
            calendar.date(
                byAdding: .day,
                value: $0,
                to: week.start
            )
        }
    }

    // MARK: - Day Colors

    private func dayColor(for date: Date) -> Color {
        switch viewModel.status(for: date) {
        case .learned:
            return Color("D_Orange").opacity(0.15)

        case .frozen:
            return Color("FreezeAccent").opacity(0.15)

        case nil:
            return Calendar.current.isDateInToday(date)
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

    // MARK: - View

    var body: some View {
        VStack(spacing: 0) {

            // MARK: Header

            VStack(alignment: .leading, spacing: 4) {
                Text("Activity")
                    .font(.system(size: 28, weight: .bold))

                Text(
                    Date.now,
                    format: .dateTime
                        .weekday(.wide)
                        .day()
                        .month(.wide)
                )
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // MARK: Weekly Calendar

            HStack(spacing: 0) {
                ForEach(weekDates, id: \.self) { date in
                    VStack(spacing: 6) {
                        Text(
                            date,
                            format: .dateTime.weekday(.narrow)
                        )
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.primary)

                        Text(date, format: .dateTime.day())
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(dayTextColor(for: date))
                            .frame(width: 44, height: 44)
                            .background(
                                dayColor(for: date),
                                in: Circle()
                            )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 20)

            // MARK: Activity Statistics

            HStack(spacing: 12) {

                // Learned Days
                VStack(spacing: 2) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color("D_Orange"))

                    Text("\(viewModel.learnedDays) days")
                        .font(.system(size: 16, weight: .semibold))

                    Text("Learned")
                        .font(.system(size: 12, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 90)
                .glassEffect(
                    .regular,
                    in: .rect(cornerRadius: 24)
                )

                // Frozen Days
                VStack(spacing: 2) {
                    Image(systemName: "snowflake")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color("FreezeAccent"))

                    Text("\(viewModel.freezesUsed) days")
                        .font(.system(size: 16, weight: .semibold))

                    Text("Freezed")
                        .font(.system(size: 12, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 90)
                .glassEffect(
                    .regular,
                    in: .rect(cornerRadius: 24)
                )
            }
            .padding(.top, 8)

            Spacer()
                .frame(height: 48)

            // MARK: Log as Learned Button

            // Disable only when today's status is Learned.
            // Allow switching from Frozen to Learned.
            Button {
                viewModel.logAsLearned()
            } label: {
                Text(
                    viewModel.isTodayLearned
                        ? "Logged as Learned"
                        : "Log as Learned"
                )
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 272, height: 272)
            }
            .buttonStyle(.glassProminent)
            .tint(
                viewModel.isTodayLearned
                    ? Color(white: 0.27)
                    : Color("D_Orange")
            )
            .buttonBorderShape(.circle)
            .disabled(viewModel.isTodayLearned)
            .padding(.bottom, 48)

            // MARK: Freeze Button

            // Disable when Frozen or when no freezes remain.
            // Allow switching from Learned to Frozen.
            Button {
                viewModel.freezeDay()
            } label: {
                Text(
                    viewModel.isTodayFrozen
                        ? "Freezed for a day"
                        : "Freeze for a day"
                )
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(
                    viewModel.canFreeze ? .white : .gray
                )
                .frame(width: 260, height: 44)
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

            // MARK: Freeze Usage

            Text("\(viewModel.freezesUsed) out of 2 Freezes used")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Preview

#Preview {
    let viewModel = LearningViewModel()
    let calendar = Calendar.current

    // Sample records for preview only.
    for daysAgo in 1...4 {
        if let date = calendar.date(
            byAdding: .day,
            value: -daysAgo,
            to: Date()
        ) {
            viewModel.dailyRecords.append(
                DailyRecord(
                    date: date,
                    status: .learned
                )
            )
        }
    }

    return ActivityView(viewModel: viewModel)
}
