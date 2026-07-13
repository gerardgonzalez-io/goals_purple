import Foundation

struct ProgressPlanChartData
{
    enum TimeRange: String, CaseIterable, Identifiable
    {
        case currentWeek = "7 Days"
        case currentMonth = "30 Days"

        var id: Self { self }
    }

    struct Point: Identifiable
    {
        let day: Date
        let hours: Double

        var id: Date { day }
    }

    struct Series: Identifiable
    {
        let name: String
        let points: [Point]

        var id: String { name }
    }

    static let planSeriesName = "Plan"
    static let progressSeriesName = "Progress"

    static func series(
        for topicID: UUID,
        sessions: [StudySession],
        goals: [Goal],
        timeRange: TimeRange,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> [Series]
    {
        let days = days(in: timeRange, now: now, calendar: calendar)
        let topicSessions = sessions.filter { $0.topicID == topicID }
        let topicGoals = goals
            .filter { $0.topicID == topicID }
            .sorted { $0.createdAt < $1.createdAt }

        var cumulativePlan: TimeInterval = 0
        var cumulativeProgress: TimeInterval = 0
        var planPoints: [Point] = []
        var progressPoints: [Point] = []

        for day in days
        {
            cumulativePlan += targetSeconds(on: day, goals: topicGoals, calendar: calendar)
            cumulativeProgress += TimeCalculator.dailyTime(
                from: topicSessions,
                on: day,
                calendar: calendar
            )

            planPoints.append(Point(day: day, hours: cumulativePlan / 3_600))
            progressPoints.append(Point(day: day, hours: cumulativeProgress / 3_600))
        }

        return [
            Series(name: planSeriesName, points: planPoints),
            Series(name: progressSeriesName, points: progressPoints)
        ]
    }

    static func days(
        in timeRange: TimeRange,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> [Date]
    {
        switch timeRange
        {
        case .currentWeek:
            return currentMondayToSunday(now: now, calendar: calendar)
        case .currentMonth:
            return currentMonthDays(now: now, calendar: calendar)
        }
    }

    private static func currentMondayToSunday(now: Date, calendar: Calendar) -> [Date]
    {
        let today = calendar.startOfDay(for: now)
        let weekday = calendar.component(.weekday, from: today)
        let daysSinceMonday = (weekday + 5) % 7

        guard let monday = calendar.date(byAdding: .day, value: -daysSinceMonday, to: today) else
        {
            return []
        }

        return (0..<7).compactMap
        { offset in
            calendar.date(byAdding: .day, value: offset, to: monday)
        }
    }

    private static func currentMonthDays(now: Date, calendar: Calendar) -> [Date]
    {
        guard let monthInterval = calendar.dateInterval(of: .month, for: now),
              let dayRange = calendar.range(of: .day, in: .month, for: now)
        else
        {
            return []
        }

        return dayRange.compactMap
        { day in
            calendar.date(byAdding: .day, value: day - 1, to: monthInterval.start)
        }
    }

    private static func targetSeconds(
        on day: Date,
        goals: [Goal],
        calendar: Calendar
    ) -> TimeInterval
    {
        guard let goal = goals.last(where: { goal in
            calendar.startOfDay(for: goal.createdAt) <= day
        }) else
        {
            return 0
        }

        return goal.targetSecondsPerDay
    }
}
