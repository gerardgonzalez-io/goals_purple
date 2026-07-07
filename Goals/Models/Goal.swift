import Foundation
import SwiftData

@Model
final class Goal
{
    var id: UUID
    var topicID: UUID
    var targetSecondsPerDay: TimeInterval
    var createdAt: Date

    init(
        id: UUID = UUID(),
        topicID: UUID,
        targetSecondsPerDay: TimeInterval,
        createdAt: Date = .now
    )
    {
        self.id = id
        self.topicID = topicID
        self.targetSecondsPerDay = targetSecondsPerDay
        self.createdAt = createdAt
    }
}

extension Goal
{
    static let sample = sampleData[0]
    static let globalGoalSample = sampleData[1]
    static let focusedGoalSample = sampleData[2]

    static let sampleData = [
        Goal(
            topicID: Topic.sampleData[0].id,
            targetSecondsPerDay: 3_600,
            createdAt: .now.addingTimeInterval(-172_800)
        ),
        Goal(
            topicID: Topic.sampleData[1].id,
            targetSecondsPerDay: 7_200,
            createdAt: .now.addingTimeInterval(-86_400)
        ),
        Goal(
            topicID: Topic.sampleData[1].id,
            targetSecondsPerDay: 5_400,
            createdAt: .now
        )
    ]
}
