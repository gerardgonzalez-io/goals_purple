import SwiftData
import SwiftUI

struct StreakView: View
{
    @Query private var allSessions: [StudySession]

    let topicID: UUID
    let topicName: String

    private let streakCalculator = StreakCalculator()

    private var topicSessions: [StudySession]
    {
        allSessions.filter { $0.topicID == topicID }
    }

    private var currentStreak: Int
    {
        streakCalculator.calculateStreak(for: topicSessions)
    }

    var body: some View
    {
        VStack(alignment: .leading, spacing: 16)
        {
            Text(topicName)
                .font(.headline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
    
            Text("Your streaks")
                .font(.subheadline)
                .foregroundStyle(.secondary)
    
            StreakSummaryCard(
                title: "Current streak",
                current: currentStreak,
                subtitle: "Consecutive study days up to today or yesterday."
            )
            .frame(maxWidth: .infinity)
            .frame(height: 300)

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .navigationTitle("Streak")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview
{
    NavigationStack
    {
        StreakView(topicID: UUID(), topicName: "Mathematics")
            .sampleDataContainer()
    }
}
