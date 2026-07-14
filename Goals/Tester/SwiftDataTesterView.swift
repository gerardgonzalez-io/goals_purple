import SwiftData
import SwiftUI

struct SwiftDataTesterView: View
{
    var body: some View
    {
        //NavigationStack
        //{
            List
            {
                TopicRegistersView()
                GoalRegistersView()
                StudySessionRegistersView()
                SessionIntervalRegistersView()
            }
            //.navigationTitle("SwiftData Tester")
        //}
    }
}

private struct TopicRegistersView: View
{
    @Query(sort: \Topic.name) private var topics: [Topic]

    var body: some View
    {
        Section("Topics (\(topics.count))")
        {
            if topics.isEmpty
            {
                EmptyRegisterRow(message: "No topics stored.")
            }
            else
            {
                ForEach(topics, id: \.id)
                { topic in
                    RegisterCard(title: topic.name)
                    {
                        RegisterValueRow(label: "id", value: topic.id.uuidString)
                        RegisterValueRow(label: "name", value: topic.name)
                    }
                }
            }
        }
    }
}

private struct GoalRegistersView: View
{
    @Query(sort: \Goal.createdAt, order: .reverse) private var goals: [Goal]

    var body: some View
    {
        Section("Goals (\(goals.count))")
        {
            if goals.isEmpty
            {
                EmptyRegisterRow(message: "No goals stored.")
            }
            else
            {
                ForEach(goals, id: \.id)
                { goal in
                    RegisterCard(title: formattedDate(goal.createdAt))
                    {
                        RegisterValueRow(label: "id", value: goal.id.uuidString)
                        RegisterValueRow(label: "topicID", value: goal.topicID.uuidString)
                        RegisterValueRow(label: "targetSecondsPerDay", value: formattedSeconds(goal.targetSecondsPerDay))
                        RegisterValueRow(label: "createdAt", value: formattedDate(goal.createdAt))
                    }
                }
            }
        }
    }
}

private struct StudySessionRegistersView: View
{
    @Query(sort: \StudySession.startDate, order: .reverse) private var sessions: [StudySession]

    var body: some View
    {
        Section("Study Sessions (\(sessions.count))")
        {
            if sessions.isEmpty
            {
                EmptyRegisterRow(message: "No study sessions stored.")
            }
            else
            {
                ForEach(sessions, id: \.id)
                { session in
                    RegisterCard(title: formattedDate(session.startDate))
                    {
                        RegisterValueRow(label: "id", value: session.id.uuidString)
                        RegisterValueRow(label: "topicID", value: session.topicID.uuidString)
                        RegisterValueRow(label: "startDate", value: formattedDate(session.startDate))
                        RegisterValueRow(label: "endDate", value: formattedOptionalDate(session.endDate))
                        RegisterValueRow(label: "durationSeconds", value: formattedSeconds(session.durationSeconds))
                        RegisterValueRow(label: "sessionIntervals", value: "\(session.sessionIntervals.count)")
                    }
                }
            }
        }
    }
}

private struct SessionIntervalRegistersView: View
{
    @Query(sort: \SessionInterval.startDate, order: .reverse) private var intervals: [SessionInterval]

    var body: some View
    {
        Section("Session Intervals (\(intervals.count))")
        {
            if intervals.isEmpty
            {
                EmptyRegisterRow(message: "No session intervals stored.")
            }
            else
            {
                ForEach(intervals, id: \.id)
                { interval in
                    RegisterCard(title: formattedDate(interval.startDate))
                    {
                        RegisterValueRow(label: "id", value: interval.id.uuidString)
                        RegisterValueRow(label: "startDate", value: formattedDate(interval.startDate))
                        RegisterValueRow(label: "endDate", value: formattedOptionalDate(interval.endDate))
                        RegisterValueRow(label: "durationSeconds", value: formattedSeconds(interval.durationSeconds))
                        RegisterValueRow(label: "studySession", value: interval.studySession?.id.uuidString ?? "nil")
                    }
                }
            }
        }
    }
}

private struct RegisterCard<Content: View>: View
{
    let title: String
    @ViewBuilder let content: Content

    var body: some View
    {
        DisclosureGroup
        {
            VStack(alignment: .leading, spacing: 8)
            {
                content
            }
            .padding(.top, 8)
        }
        label:
        {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
        }
    }
}

private struct RegisterValueRow: View
{
    let label: String
    let value: String

    var body: some View
    {
        VStack(alignment: .leading, spacing: 3)
        {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.caption.monospaced())
                .textSelection(.enabled)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct EmptyRegisterRow: View
{
    let message: String

    var body: some View
    {
        Text(message)
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
}

private func formattedDate(_ date: Date) -> String
{
    date.formatted(date: .abbreviated, time: .standard)
}

private func formattedOptionalDate(_ date: Date?) -> String
{
    guard let date else { return "nil" }
    return formattedDate(date)
}

private func formattedSeconds(_ seconds: TimeInterval) -> String
{
    let value = Int(seconds)
    let hours = value / 3_600
    let minutes = (value % 3_600) / 60
    let remainingSeconds = value % 60
    return "\(value)s (\(hours)h \(minutes)m \(remainingSeconds)s)"
}

#Preview
{
    SwiftDataTesterView()
        .sampleDataContainer()
}
