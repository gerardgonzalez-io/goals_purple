import Charts
import SwiftData
import SwiftUI

struct ProgressPlanChartView: View
{
    @Query private var allSessions: [StudySession]
    @Query private var allGoals: [Goal]

    let topicID: UUID
    let topicName: String

    @Environment(\.calendar) private var calendar
    @Environment(\.colorScheme) private var colorScheme
    @State private var timeRange: ProgressPlanChartData.TimeRange = .currentWeek
    @State private var rawSelectedDate: Date?
    @State private var rawSelectedRange: ClosedRange<Date>?

    private var chartData: [ProgressPlanChartData.Series]
    {
        ProgressPlanChartData.series(
            for: topicID,
            sessions: completedSessions,
            goals: allGoals,
            timeRange: timeRange,
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

    private var selectedDate: Date?
    {
        if let rawSelectedDate
        {
            return chartData.first?.points.first
            { point in
                (point.day..<endOfDay(for: point.day)).contains(rawSelectedDate)
            }?.day
        }
        else if let selectedRange, selectedRange.lowerBound == selectedRange.upperBound
        {
            return selectedRange.lowerBound
        }

        return nil
    }

    private var selectedRange: ClosedRange<Date>?
    {
        guard let rawSelectedRange else { return nil }

        let lower = chartData.first?.points.first
        { point in
            (point.day..<endOfDay(for: point.day)).contains(rawSelectedRange.lowerBound)
        }?.day

        let upper = chartData.first?.points.first
        { point in
            (point.day..<endOfDay(for: point.day)).contains(rawSelectedRange.upperBound)
        }?.day

        guard let lower, let upper else { return nil }
        return min(lower, upper)...max(lower, upper)
    }

    private let colorPerSeries: [String: Color] = [
        ProgressPlanChartData.planSeriesName: .green,
        ProgressPlanChartData.progressSeriesName: .purple
    ]

    var body: some View
    {
        List
        {
            VStack(alignment: .leading)
            {
                Picker("Time Range", selection: $timeRange)
                {
                    ForEach(ProgressPlanChartData.TimeRange.allCases)
                    { range in
                        Text(range.rawValue)
                            .tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.bottom)

                VStack(alignment: .leading, spacing: 1)
                {
                    title
                    legend
                }
                .opacity(rawSelectedDate == nil && rawSelectedRange == nil ? 1 : 0)

                Spacer(minLength: 6)

                ProgressPlanChart(
                    data: chartData,
                    rawSelectedDate: $rawSelectedDate,
                    rawSelectedRange: $rawSelectedRange,
                    timeRange: timeRange,
                    colorPerSeries: colorPerSeries
                )
                .frame(height: 240)

                Spacer(minLength: 15)

                descriptionText
                    .font(progressPlanDescriptionFont)
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .navigationTitle("Progress vs Plan")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDisabled(true)
        .onChange(of: timeRange)
        {
            rawSelectedDate = nil
            rawSelectedRange = nil
        }
    }

    private var title: some View
    {
        VStack(alignment: .leading)
        {
            Text("Progress vs Plan")
                .font(progressPlanPreTitleFont)
                .foregroundStyle(.secondary)
            Text(topicName)
                .font(progressPlanTitleFont)
        }
    }

    private var legend: some View
    {
        HStack
        {
            HStack(spacing: 5)
            {
                progressPlanLegendSquare
                Text(ProgressPlanChartData.planSeriesName)
                    .font(progressPlanLabelFont)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 5)
            {
                progressPlanLegendCircle
                Text(ProgressPlanChartData.progressSeriesName)
                    .font(progressPlanLabelFont)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var descriptionText: Text
    {
        guard let plan = chartData.first(where: { $0.name == ProgressPlanChartData.planSeriesName })?.points.last?.hours,
              let progress = chartData.first(where: { $0.name == ProgressPlanChartData.progressSeriesName })?.points.last?.hours
        else
        {
            return Text("No chart data is available yet.")
        }

        let period = timeRange == .currentWeek ? "this week" : "this month"
        return Text("So far, you have studied \(formattedHours(progress)) against \(formattedHours(plan)) planned for \(period).")
    }

    private func endOfDay(for date: Date) -> Date
    {
        calendar.date(byAdding: .day, value: 1, to: date) ?? date
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

private struct ProgressPlanChart: View
{
    let data: [ProgressPlanChartData.Series]
    @Binding var rawSelectedDate: Date?
    @Binding var rawSelectedRange: ClosedRange<Date>?
    let timeRange: ProgressPlanChartData.TimeRange
    let colorPerSeries: [String: Color]

    @Environment(\.calendar) private var calendar
    @Environment(\.colorScheme) private var colorScheme

    private var selectedDate: Date?
    {
        if let rawSelectedDate
        {
            return data.first?.points.first
            { point in
                (point.day..<endOfDay(for: point.day)).contains(rawSelectedDate)
            }?.day
        }
        else if let selectedRange, selectedRange.lowerBound == selectedRange.upperBound
        {
            return selectedRange.lowerBound
        }

        return nil
    }

    private var selectedRange: ClosedRange<Date>?
    {
        guard let rawSelectedRange else { return nil }

        let lower = data.first?.points.first
        { point in
            (point.day..<endOfDay(for: point.day)).contains(rawSelectedRange.lowerBound)
        }?.day

        let upper = data.first?.points.first
        { point in
            (point.day..<endOfDay(for: point.day)).contains(rawSelectedRange.upperBound)
        }?.day

        guard let lower, let upper else { return nil }
        return min(lower, upper)...max(lower, upper)
    }

    var body: some View
    {
        Chart
        {
            lineMarks
            selectionMarks
        }
        .chartForegroundStyleScale { colorPerSeries[$0] ?? .primary }
        .chartSymbolScale(range: [.square, .circle])
        .chartXAxis
        {
            AxisMarks(values: axisValues)
            { _ in
                AxisTick()
                AxisGridLine()
                AxisValueLabel(format: axisLabelFormat, centered: true)
            }
        }
        .chartYAxis
        {
            AxisMarks(position: .trailing)
            { value in
                AxisGridLine()
                AxisValueLabel
                {
                    if let hours = value.as(Double.self)
                    {
                        Text("\(hours.formatted(.number.precision(.fractionLength(0))))h")
                    }
                }
            }
        }
        .chartLegend(.hidden)
        .chartXSelection(value: $rawSelectedDate)
        .chartXSelection(range: $rawSelectedRange)
    }

    @ChartContentBuilder
    private var lineMarks: some ChartContent
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
            .interpolationMethod(.catmullRom)
        }
    }

    @ChartContentBuilder
    private var selectionMarks: some ChartContent
    {
        if let selectedDate
        {
            RuleMark(x: .value("Selected", selectedDate, unit: .day))
                .foregroundStyle(Color.gray.opacity(0.3))
                .offset(yStart: -10)
                .zIndex(-1)
                .annotation(
                    position: .top,
                    spacing: 0,
                    overflowResolution: .init(x: .fit(to: .chart), y: .disabled)
                )
                {
                    valueSelectionPopover
                }
        }
        else if let selectedRange
        {
            Plot
            {
                RuleMark(x: .value("Selected upper bound", selectedRange.upperBound, unit: .day))
                RuleMark(x: .value("Selected lower bound", selectedRange.lowerBound, unit: .day))
            }
            .foregroundStyle(Color.gray.opacity(0.3))
            .offset(yStart: -10)
            .zIndex(-1)
            .annotation(
                position: .top,
                spacing: 0,
                overflowResolution: .init(x: .fit(to: .chart), y: .disabled)
            )
            { context in
                let markWidth = context.targetSize.width

                rangeSelectionPopover
                    .frame(minWidth: markWidth > 0 ? markWidth : 0, alignment: .leading)
                    .fixedSize()
                    .padding(6)
                    .background
                    {
                        RoundedRectangle(cornerRadius: 4)
                            .foregroundStyle(Color.gray.opacity(0.12))
                    }
            }
        }
    }

    @ViewBuilder
    private var valueSelectionPopover: some View
    {
        if let selectedDate,
           let values = valuesBySeries(on: selectedDate)
        {
            VStack(alignment: .leading)
            {
                Text("Total by \(selectedDate, format: .dateTime.weekday(.wide).day().month(.abbreviated))")
                    .font(progressPlanPreTitleFont)
                    .foregroundStyle(.secondary)
                    .fixedSize()

                HStack(spacing: 20)
                {
                    ForEach(values)
                    { value in
                        chartValueColumn(value)
                    }
                }
            }
            .padding(6)
            .background
            {
                RoundedRectangle(cornerRadius: 4)
                    .foregroundStyle(Color.gray.opacity(0.12))
            }
        }
    }

    @ViewBuilder
    private var rangeSelectionPopover: some View
    {
        if let selectedRange,
           let values = valuesBySeries(in: selectedRange)
        {
            VStack(alignment: .leading)
            {
                Text("Added from \(selectedRange.lowerBound, format: .dateTime.day().month(.abbreviated)) to \(selectedRange.upperBound, format: .dateTime.day().month(.abbreviated))")
                    .font(progressPlanPreTitleFont)
                    .foregroundStyle(.secondary)
                    .fixedSize()

                HStack(spacing: 20)
                {
                    ForEach(values)
                    { value in
                        chartValueColumn(value)
                    }
                }
            }
        }
    }

    private var axisValues: AxisMarkValues
    {
        switch timeRange
        {
        case .currentWeek:
            return .stride(by: .day)
        case .currentMonth:
            return .stride(by: .day, count: 7)
        }
    }

    private var axisLabelFormat: Date.FormatStyle
    {
        switch timeRange
        {
        case .currentWeek:
            return .dateTime.weekday(.abbreviated)
        case .currentMonth:
            return .dateTime.day()
        }
    }

    private func chartValueColumn(_ value: SeriesValue) -> some View
    {
        VStack(alignment: .leading, spacing: 1)
        {
            HStack(alignment: .lastTextBaseline, spacing: 4)
            {
                Text(formattedHours(value.hours))
                    .font(progressPlanTitleFont)
                    .foregroundColor(colorPerSeries[value.series])
                    .blendMode(colorScheme == .light ? .plusDarker : .normal)

                Text("hours")
                    .font(progressPlanPreTitleFont)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 6)
            {
                if value.series == ProgressPlanChartData.planSeriesName
                {
                    progressPlanLegendSquare
                }
                else
                {
                    progressPlanLegendCircle
                }

                Text(value.series)
                    .font(progressPlanLabelFont)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func valuesBySeries(on selectedDate: Date) -> [SeriesValue]?
    {
        guard let index = index(of: selectedDate) else { return nil }

        return data.map
        { series in
            SeriesValue(series: series.name, hours: series.points[index].hours)
        }
    }

    private func valuesBySeries(in selectedRange: ClosedRange<Date>) -> [SeriesValue]?
    {
        guard let lowerIndex = index(of: selectedRange.lowerBound),
              let upperIndex = index(of: selectedRange.upperBound)
        else
        {
            return nil
        }

        return data.map
        { series in
            let lowerPrevious = lowerIndex > 0 ? series.points[lowerIndex - 1].hours : 0
            let upperValue = series.points[upperIndex].hours
            return SeriesValue(series: series.name, hours: max(0, upperValue - lowerPrevious))
        }
    }

    private func index(of selectedDate: Date) -> Int?
    {
        data.first?.points.firstIndex
        { point in
            calendar.isDate(point.day, inSameDayAs: selectedDate)
        }
    }

    private func endOfDay(for date: Date) -> Date
    {
        calendar.date(byAdding: .day, value: 1, to: date) ?? date
    }

    private func formattedHours(_ hours: Double) -> String
    {
        if hours < 1
        {
            return "\(Int((hours * 60).rounded()))m"
        }

        return hours.formatted(.number.precision(.fractionLength(0...1)))
    }
}

private struct SeriesValue: Identifiable
{
    let series: String
    let hours: Double

    var id: String { series }
}

@ViewBuilder
private var progressPlanLegendSquare: some View
{
    RoundedRectangle(cornerRadius: 1)
        .stroke(lineWidth: 2)
        .frame(width: 5.3, height: 5.3)
        .foregroundColor(.green)
        .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 0))
}

@ViewBuilder
private var progressPlanLegendCircle: some View
{
    Circle()
        .stroke(lineWidth: 2)
        .frame(width: 5.7, height: 5.7)
        .foregroundColor(.purple)
        .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 0))
}

#if os(macOS)
private let progressPlanTitleFont: Font = .title.bold()
#else
private let progressPlanTitleFont: Font = .title2.bold()
#endif

#if os(macOS)
private let progressPlanPreTitleFont: Font = .headline
#else
private let progressPlanPreTitleFont: Font = .callout
#endif

#if os(macOS)
private let progressPlanLabelFont: Font = .subheadline
#else
private let progressPlanLabelFont: Font = .caption2
#endif

#if os(macOS)
private let progressPlanDescriptionFont: Font = .body
#else
private let progressPlanDescriptionFont: Font = .subheadline
#endif

#Preview
{
    NavigationStack
    {
        ProgressPlanChartView(
            topicID: Topic.sample.id,
            topicName: Topic.sample.name
        )
        .sampleDataContainer()
    }
}
