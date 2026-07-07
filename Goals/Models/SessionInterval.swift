import Foundation
import SwiftData

@Model
final class SessionInterval
{
    var id: UUID
    var startDate: Date
    var endDate: Date?
    var studySession: StudySession?

    var durationSeconds: TimeInterval
    {
        guard let endDate else { return 0 }
        let duration = endDate.timeIntervalSince(startDate)
        return max(0, duration)
    }

    init(
        id: UUID = UUID(),
        startDate: Date,
        endDate: Date? = nil,
        studySession: StudySession? = nil
    )
    {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.studySession = studySession
    }
}
