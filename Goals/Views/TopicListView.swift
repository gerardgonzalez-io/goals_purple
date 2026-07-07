import SwiftData
import SwiftUI

struct TopicListView: View
{
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Topic.name) private var topics: [Topic]
    @Query private var allSessions: [StudySession]
    @Query private var allGoals: [Goal]

    @State private var isPresentingEntry = false

    private var existingNames: Set<String>
    {
        Set(topics.map
        {
            $0.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        })
    }

    @ViewBuilder
    private var content: some View
    {
        if topics.isEmpty
        {
            ContentUnavailableView(
                "No Topics Yet",
                systemImage: "list.bullet.clipboard",
                description: Text("Tap + to create your first study topic.")
            )
        }
        else
        {
            List
            {
                ForEach(topics)
                { topic in
                    NavigationLink(value: TopicRoute(topicID: topic.id, topicName: topic.name))
                    {
                        HStack
                        {
                            Text(topic.name)
                        }
                    }
                    .swipeActions
                    {
                        Button(role: .destructive)
                        {
                            deleteTopic(topic)
                        }
                        label:
                        {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }

    var body: some View
    {
        content
        .navigationTitle("Topics")
        .toolbar
        {
            //ToolbarItem(placement: .topBarTrailing)
            //{
            //    EditButton()
            //}

            ToolbarItem(placement: .topBarTrailing)
            {
                Button
                {
                    isPresentingEntry = true
                }
                label:
                {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add Topic")
            }
        }
        .sheet(isPresented: $isPresentingEntry)
        {
            NavigationStack
            {
                TopicEntryView(existingNames: existingNames)
                    .navigationTitle("New Topic")
            }
        }
        .navigationDestination(for: TopicRoute.self)
        { route in
            TopicDetailView(topicID: route.topicID,
                            topicName: route.topicName)
        }
    }

    private func deleteTopic(_ topic: Topic)
    {
        let topicID = topic.id

        for goal in allGoals where goal.topicID == topicID
        {
            modelContext.delete(goal)
        }

        for session in allSessions where session.topicID == topicID
        {
            modelContext.delete(session)
        }

        modelContext.delete(topic)

        do
        {
            try modelContext.save()
        }
        catch
        {}
    }
}

private struct TopicRoute: Hashable
{
    let topicID: UUID
    let topicName: String
}

#Preview
{
    NavigationStack
    {
        TopicListView()
            .sampleDataContainer()
        
    }
}
