//
//  DataContainer.swift
//  GratefulMoments
//
//  Created by Adolfo Gerard Montilla Gonzalez on 25-03-26.
//
import SwiftData
import SwiftUI

@Observable
@MainActor
class DataContainer
{
    static let schema = Schema([
        Topic.self,
        StudySession.self,
        SessionInterval.self,
        Goal.self
    ])

    let modelContainer: ModelContainer

    var context: ModelContext
    {
        modelContainer.mainContext
    }

    init(
        includeSampleData: Bool = false,
        modelConfiguration: ModelConfiguration? = nil
    )
    {
        let schema = Self.schema
        let modelConfiguration = modelConfiguration ?? ModelConfiguration(schema: schema, isStoredInMemoryOnly: includeSampleData)

        do
        {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])

            if includeSampleData
            {
                try loadSampleData()
            }

            try deleteUnfinishedSessions()
            try context.save()
        }
        catch
        {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    private func loadSampleData() throws
    {
        for topic in Topic.sampleData
        {
            context.insert(topic)
        }

        for studySession in StudySession.sampleData
        {
            context.insert(studySession)
        }

        for goal in Goal.sampleData
        {
            context.insert(goal)
        }
    }

    func deleteUnfinishedSessions() throws
    {
        let unfinishedSessionsDescriptor = FetchDescriptor<StudySession>(
            predicate: #Predicate { session in
                session.endDate == nil
            }
        )
        let unfinishedSessions = try context.fetch(unfinishedSessionsDescriptor)

        for session in unfinishedSessions
        {
            context.delete(session)
        }

        let unfinishedIntervalsDescriptor = FetchDescriptor<SessionInterval>(
            predicate: #Predicate { interval in
                interval.endDate == nil
            }
        )
        let unfinishedIntervals = try context.fetch(unfinishedIntervalsDescriptor)

        for interval in unfinishedIntervals
        {
            context.delete(interval)
        }
    }
}

private let sampleContainer = DataContainer(includeSampleData: true)

extension View
{
    func sampleDataContainer() -> some View
    {
        self
            .environment(sampleContainer)
            .modelContainer(sampleContainer.modelContainer)
    }
}
