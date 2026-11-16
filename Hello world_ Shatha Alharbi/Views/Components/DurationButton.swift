//
//  DurationButton.swift
//  Hello world_ Shatha Alharbi
//
//  Created by Shatha Alharbi on 11/11/2026.
//


import SwiftUI

struct DurationButton: View {

    let title: String
    let duration: GoalDuration

    @Binding var selectedDuration: GoalDuration

    private var isSelected: Bool {
        selectedDuration == duration
    }

    var body: some View {

        Button {
            selectedDuration = duration
        } label: {

            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(isSelected ? .white : .secondary)
                .frame(width: 84, height: 46)
                .contentShape(Capsule())
                .glassEffect(
                    isSelected
                        ? .regular.tint(Color("D_Orange"))
                        : .regular,
                    in: .capsule
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    DurationButton(
        title: "Week",
        duration: .week,
        selectedDuration: .constant(.week)
    )
}
