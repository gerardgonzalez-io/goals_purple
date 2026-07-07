import Foundation
import SwiftData

@Model
final class StudySession
{
    var id: UUID
    var topicID: UUID
    var startDate: Date
    var endDate: Date?
    
    @Relationship(deleteRule: .cascade)
    var sessionIntervals: [SessionInterval]

    var durationSeconds: TimeInterval
    {
        guard let endDate else { return 0 }
        let duration = endDate.timeIntervalSince(startDate)
        return max(0, duration)
    }

    init(
        id: UUID = UUID(),
        topicID: UUID,
        startDate: Date,
        endDate: Date? = nil,
        sessionIntervals: [SessionInterval] = []
    )
    {
        self.id = id
        self.topicID = topicID
        self.startDate = startDate
        self.endDate = endDate
        self.sessionIntervals = sessionIntervals
    }
}

extension StudySession
{
    static let sample = sampleData[0]
    static let longSample = sampleData[1]
    static let shortSample = sampleData[2]

    static let sampleData = [
        StudySession(
            topicID: Topic.sampleData[0].id,
            startDate: .now.addingTimeInterval(-7_200),
            endDate: .now.addingTimeInterval(-3_600), // Session: 1h
            sessionIntervals: [
                SessionInterval(
                    startDate: .now.addingTimeInterval(-7_200),
                    endDate: .now.addingTimeInterval(-3_600) // Interval: 1h
                )
            ]
        ),
        StudySession(
            topicID: Topic.sampleData[1].id,
            startDate: .now.addingTimeInterval(-172_800),
            endDate: .now.addingTimeInterval(-151_200), // Session: 6h
            sessionIntervals: [
                SessionInterval(
                    startDate: .now.addingTimeInterval(-172_800),
                    endDate: .now.addingTimeInterval(-165_600) // Interval: 2h
                ),
                SessionInterval(
                    startDate: .now.addingTimeInterval(-160_200),
                    endDate: .now.addingTimeInterval(-153_000) // Interval: 2h
                )
            ]
        ),
        StudySession(
            topicID: Topic.sampleData[2].id,
            startDate: .now.addingTimeInterval(-86_400),
            endDate: .now.addingTimeInterval(-79_200), // Session: 2h
            sessionIntervals: [
                SessionInterval(
                    startDate: .now.addingTimeInterval(-86_400),
                    endDate: .now.addingTimeInterval(-85_200) // Interval: 20m
                ),
                SessionInterval(
                    startDate: .now.addingTimeInterval(-84_600),
                    endDate: .now.addingTimeInterval(-83_700) // Interval: 15m
                ),
                SessionInterval(
                    startDate: .now.addingTimeInterval(-83_100),
                    endDate: .now.addingTimeInterval(-79_500) // Interval: 1h
                ),
                SessionInterval(
                    startDate: .now.addingTimeInterval(-79_440),
                    endDate: .now.addingTimeInterval(-79_260) // Interval: 3m
                )
            ]
        ),
        StudySession(
            topicID: Topic.sampleData[0].id,
            startDate: .now.addingTimeInterval(-18_000),
            endDate: .now.addingTimeInterval(-9_000), // Session: 2h30m
            sessionIntervals: [
                SessionInterval(
                    startDate: .now.addingTimeInterval(-18_000),
                    endDate: .now.addingTimeInterval(-9_000) // Interval: 2h30m
                )
            ]
        ),
        StudySession(
            topicID: Topic.sampleData[1].id,
            startDate: .now.addingTimeInterval(-10_800),
            endDate: .now.addingTimeInterval(0), // Session: 3h
            sessionIntervals: [
                SessionInterval(
                    startDate: .now.addingTimeInterval(-10_800),
                    endDate: .now.addingTimeInterval(-9_300) // Interval: 25m
                ),
                SessionInterval(
                    startDate: .now.addingTimeInterval(-9_180),
                    endDate: .now.addingTimeInterval(-7_980) // Interval: 20m
                ),
                SessionInterval(
                    startDate: .now.addingTimeInterval(-7_800),
                    endDate: .now.addingTimeInterval(-6_900) // Interval: 15m
                ),
                SessionInterval(
                    startDate: .now.addingTimeInterval(-6_600),
                    endDate: .now.addingTimeInterval(-3_000) // Interval: 1h
                ),
                SessionInterval(
                    startDate: .now.addingTimeInterval(-2_880),
                    endDate: .now.addingTimeInterval(-2_700) // Interval: 3m
                ),
                SessionInterval(
                    startDate: .now.addingTimeInterval(-2_520),
                    endDate: .now.addingTimeInterval(-2_100) // Interval: 7m
                )
            ]
        )
    ]
}
