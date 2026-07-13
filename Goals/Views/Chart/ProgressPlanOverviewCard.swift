import Charts
import SwiftData
import SwiftUI

struct ProgressPlanOverviewCard: View
{
    @Query private var allSessions: [StudySession]
    @Query private var allGoals: [Goal]

    let topicID: UUID
    let topicName: String

    @Environment(\.calendar) private var calendar

    private var chartData: [ProgressPlanChartData.Series]
    {
        ProgressPlanChartData.series(
            for: topicID,
            sessions: completedSessions,
            goals: allGoals,
            timeRange: .currentWeek,
            calendar: calendar
        )
    }

    private var completedSessions: [StudySession]
    {
        allSessions.filter
        { session in
            session.topicID == topicID && session.sessionIntervals.allSatisfy { $0.endDate != nil }
        }
    }

    private var summaryText: String
    {
        guard let plan = chartData.first(where: { $0.name == ProgressPlanChartData.planSeriesName })?.points.last?.hours,
              let progress = chartData.first(where: { $0.name == ProgressPlanChartData.progressSeriesName })?.points.last?.hours
        else
        {
            return "No progress data yet"
        }

        return "\(formattedHours(progress)) studied of \(formattedHours(plan)) planned"
    }

    var body: some View
    {
        HStack(alignment: .center, spacing: 12)
        {
            VStack(alignment: .leading, spacing: 8)
            {
                VStack(alignment: .leading, spacing: 2)
                {
                    Text("Progress vs Plan")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(topicName)
                        .font(.title2.bold())
                        .lineLimit(1)
                }

                ProgressPlanOverviewChart(data: chartData)
                    .frame(height: 110)

                Text(summaryText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Image(systemName: "chevron.right")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func formattedHours(_ hours: Double) -> String
    {
        if hours < 1
        {
            return "\(Int((hours * 60).rounded()))m"
        }

        return "\(hours.formatted(.number.precision(.fractionLength(0...1))))h"
    }
}

private struct ProgressPlanOverviewChart: View
{
    let data: [ProgressPlanChartData.Series]

    private let symbolSize: CGFloat = 100
    private let lineWidth: CGFloat = 3

    private var latestProgressPoint: ProgressPlanChartData.Point?
    {
        data.first { $0.name == ProgressPlanChartData.progressSeriesName }?.points.last
    }

    var body: some View
    {
        Chart
        {
            ForEach(data)
            { series in
                ForEach(series.points)
                { point in
                    LineMark(
                        x: .value("Day", point.day, unit: .day),
                        y: .value("Hours", point.hours)
                    )
                }
                .foregroundStyle(by: .value("Series", series.name))
                .symbol(by: .value("Series", series.name))
            }
            .interpolationMethod(.catmullRom)
            .lineStyle(StrokeStyle(lineWidth: lineWidth))
            .symbolSize(symbolSize)

            if let latestProgressPoint
            {
                PointMark(
                    x: .value("Day", latestProgressPoint.day, unit: .day),
                    y: .value("Hours", latestProgressPoint.hours)
                )
                .foregroundStyle(.purple)
                .symbolSize(symbolSize)
            }
        }
        .chartForegroundStyleScale([
            ProgressPlanChartData.planSeriesName: .green,
            ProgressPlanChartData.progressSeriesName: .purple
        ])
        .chartSymbolScale(range: [.square, .circle])
        .chartXAxis
        {
            AxisMarks(values: .stride(by: .day))
            { _ in
                AxisTick()
                AxisGridLine()
                AxisValueLabel(format: .dateTime.weekday(.narrow), centered: true)
            }
        }
        .chartYAxis(.hidden)
        .chartYScale(range: .plotDimension(startPadding: 8, endPadding: 18))
        .chartLegend(.hidden)
    }
}

#Preview
{
    ProgressPlanOverviewCard(topicID: Topic.sample.id, topicName: Topic.sample.name)
        .padding()
        .sampleDataContainer()
}
