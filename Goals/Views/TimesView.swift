import SwiftData
import SwiftUI

struct TimesView: View
{
    @Query private var allSessions: [StudySession]

    let topicID: UUID
    let topicName: String

    private var topicSessions: [StudySession]
    {
        allSessions.filter { $0.topicID == topicID }
    }

    private var dailyTime: TimeInterval
    {
        TimeCalculator.dailyTime(from: topicSessions)
    }

    private var totalTime: TimeInterval
    {
        TimeCalculator.totalTime(from: topicSessions)
    }

    var body: some View
    {
        VStack(spacing: 16)
        {
            TimeSummaryCard(
                title: "Today",
                value: formatted(time: dailyTime),
                subtitle: "Study time today",
                isPrimary: true
            )

            TimeSummaryCard(
                title: "Total",
                value: formatted(time: totalTime),
                subtitle: "Total time spent on this topic",
                isPrimary: false
            )

            Spacer()
        }
        .padding()
        .navigationTitle("Times")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func formatted(time: TimeInterval) -> String
    {
        let value = Int(time)
        let hours = value / 3_600
        let minutes = (value % 3_600) / 60
        return "\(hours)h \(String(format: "%02d", minutes))m"
    }
}

#Preview
{
    NavigationStack
    {
        TimesView(topicID: UUID(), topicName: "Mathematics")
    }
    .modelContainer(for: [StudySession.self], inMemory: true)
}
