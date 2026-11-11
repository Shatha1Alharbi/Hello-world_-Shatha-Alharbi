//
//  OnboardingView.swift
//  Hello world_ Shatha Alharbi
//
//  Created by Shatha Alharbi on 10/11/2026.
//

import SwiftUI

struct OnboardingView: View {
    @State private var goalName = ""
    @State private var selectedDuration: GoalDuration = .week
    var body: some View {
        
        ZStack {
            Color("AppBackground")
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 43))
                    .foregroundStyle(Color("D_Orange"))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 57)
                
                // MARK: - Welcome Section

                VStack(alignment: .leading, spacing: 4) {
                    Text("Hello \(Text("Learner").bold())")
                        .font(.largeTitle)

                    Text("This app will help you learn everyday!")
                        .font(.system(size: 17))
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 80)
                
                // MARK: - Goal Input

                VStack(alignment: .leading, spacing: 5) {

                    Text("I want to learn")
                        .font(.system(size: 16))

                    TextField("Swift", text: $goalName)
                        .font(.system(size: 16))

                    Divider()
                }
                .padding(.top, 37)
                
                // MARK: - Duration Selection

                VStack(alignment: .leading, spacing: 13) {

                    Text("I want to learn it in a")
                        .font(.system(size: 16))
                    
                // MARK: - Duration Buttons

                    HStack(spacing: 12) {
                        DurationButton(
                            title: "Week",
                            duration: .week,
                            selectedDuration: $selectedDuration
                        )

                        DurationButton(
                            title: "Month",
                            duration: .month,
                            selectedDuration: $selectedDuration
                        )

                        DurationButton(
                            title: "Year",
                            duration: .year,
                            selectedDuration: $selectedDuration
                        )
                    }
                    
                }
                .padding(.top, 30)
                Spacer(minLength: 0)
                
                Button {

                } label: {
                    Text("Start Learning")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.glassProminent)
                .tint(Color("D_Orange"))
                .controlSize(.regular)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 12)
                
                Text("You can edit your desire later")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                
                    .frame(maxWidth: .infinity)
                
            }
            .padding(.horizontal, 16)
            
        }
    }
        

}

#Preview {
    OnboardingView()
}
