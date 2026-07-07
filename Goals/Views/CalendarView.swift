import SwiftData
import SwiftUI

struct CalendarView: View
{
    @Query private var allSessions: [StudySession]
    @Query private var allGoals: [Goal]

    let topicID: UUID
    let topicName: String

    private let calendar = Calendar.current
    private let goalEvaluator = GoalEvaluator()
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    private var topicSessions: [StudySession]
    {
        allSessions.filter { session in
            session.topicID == topicID && session.sessionIntervals.allSatisfy { $0.endDate != nil }
        }
    }

    private var topicGoals: [Goal]
    {
        allGoals.filter
        { goal in
            goal.topicID == nil || goal.topicID == topicID
        }
    }

    private var reachedGoalsByDay: [Date: Bool]
    {
        goalEvaluator.reachedGoalsByDay(sessions: topicSessions, goals: topicGoals)
    }

    private var currentMonthDays: [Date?]
    {
        guard let monthInterval = calendar.dateInterval(of: .month, for: .now),
              let daysRange = calendar.range(of: .day, in: .month, for: .now)
        else
        {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: monthInterval.start)
        let emptyDays = firstWeekday - calendar.firstWeekday
        let leadingEmptyDays = emptyDays >= 0 ? emptyDays : emptyDays + 7
        let dates = daysRange.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: monthInterval.start)
        }

        return Array(repeating: nil, count: leadingEmptyDays) + dates
    }

    var body: some View
    {
        VStack(alignment: .leading, spacing: 16)
        {
            Text(topicName)
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(monthTitle)
                .font(.title2.bold())

            LazyVGrid(columns: columns, spacing: 8)
            {
                ForEach(weekdaySymbols, id: \.self)
                { weekday in
                    Text(weekday)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }

                ForEach(Array(currentMonthDays.enumerated()), id: \.offset)
                { _, date in
                    dayCell(for: date)
                }
            }

            HStack(spacing: 16)
            {
                Label("Met", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)

                Label("Not met", systemImage: "xmark.circle.fill")
                    .foregroundStyle(.red)

                Label("No study", systemImage: "circle")
                    .foregroundStyle(.secondary)
            }
            .font(.caption)

            Spacer()
        }
        .padding()
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var monthTitle: String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: .now)
    }

    private var weekdaySymbols: [String]
    {
        let symbols = calendar.shortStandaloneWeekdaySymbols
        let startIndex = calendar.firstWeekday - 1
        return Array(symbols[startIndex...] + symbols[..<startIndex])
    }

    private func dayCell(for date: Date?) -> some View
    {
        Group
        {
            if let date
            {
                let day = calendar.startOfDay(for: date)
                let reachedGoal = reachedGoalsByDay[day]

                VStack(spacing: 6)
                {
                    Text("\(calendar.component(.day, from: date))")
                        .font(.body.weight(.medium))

                    Image(systemName: symbolName(for: reachedGoal))
                        .font(.caption)
                        .foregroundStyle(symbolColor(for: reachedGoal))
                }
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            else
            {
                Color.clear
                    .frame(minHeight: 48)
            }
        }
    }

    private func symbolName(for reachedGoal: Bool?) -> String
    {
        guard let reachedGoal else
        {
            return "circle"
        }

        return reachedGoal ? "checkmark.circle.fill" : "xmark.circle.fill"
    }

    private func symbolColor(for reachedGoal: Bool?) -> Color
    {
        guard let reachedGoal else
        {
            return .secondary
        }

        return reachedGoal ? .green : .red
    }
}

#Preview
{
    NavigationStack
    {
        CalendarView(topicID: Topic.sample.id, topicName: Topic.sample.name)
            .sampleDataContainer()
    }
}
