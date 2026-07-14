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
    let modelContainer: ModelContainer

    var context: ModelContext
    {
        modelContainer.mainContext
    }

    init(includeSampleData: Bool = false)
    {
        let schema = Schema([
            Topic.self,
            StudySession.self,
            SessionInterval.self,
            Goal.self
        ])

        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: includeSampleData)

        do
        {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])

            if includeSampleData
            {
                try loadSampleData()
            }
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
