import Foundation
import SwiftData

@Model
final class Topic
{
    var id: UUID
    var name: String

    init(id: UUID = UUID(), name: String)
    {
        self.id = id
        self.name = name
    }
}

extension Topic
{
    static let sample = sampleData[0]
    static let longTextSample = sampleData[1]
    static let extraSample = sampleData[2]

    static let sampleData = [
        Topic(name: "Mathematics"),
        Topic(name: "Chemistry"),
        Topic(name: "History")
    ]
}
