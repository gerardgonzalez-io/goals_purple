import SwiftData
import SwiftUI

struct GoalView: View
{
    @Environment(\.modelContext) private var modelContext
    @Query private var allGoals: [Goal]

    let topicID: UUID
    let topicName: String

    @State private var selectedHours = 1

    private var topicGoals: [Goal]
    {
        allGoals
            .filter { $0.topicID == topicID }
            .sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View
    {
        Form
        {
            Section("Daily Goal")
            {
                Picker("Hours", selection: $selectedHours)
                {
                    ForEach(1...12, id: \.self)
                    { hour in
                        Text("\(hour) hour\(hour == 1 ? "" : "s")")
                            .tag(hour)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 140)
                
                Text("Changes you make here apply starting today. Past days will keep the goal that was active on those dates.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }

            Section("Goal History")
            {
                if topicGoals.isEmpty
                {
                    Text("No goals yet.")
                        .foregroundStyle(.secondary)
                }
                else
                {
                    ForEach(topicGoals, id: \.id)
                    { goal in
                        HStack
                        {
                            Text(goal.createdAt, style: .date)
                                .foregroundStyle(.primary)

                            Spacer()

                            Text(formattedGoalTime(goal.targetSecondsPerDay))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Goal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar
        {
            ToolbarItem(placement: .topBarTrailing)
            {
                Button("Save")
                {
                    saveGoal()
                }
            }
        }
    }

    private func saveGoal()
    {
        let goal = Goal(
            topicID: topicID,
            targetSecondsPerDay: TimeInterval(selectedHours * 3_600),
            createdAt: .now
        )

        do
        {
            modelContext.insert(goal)
            try modelContext.save()
        }
        catch
        {}
    }

    private func formattedGoalTime(_ seconds: TimeInterval) -> String
    {
        let hours = Int(seconds) / 3_600
        return "\(hours) hour\(hours == 1 ? "" : "s")"
    }

}

#Preview
{
    NavigationStack
    {
        GoalView(topicID: Topic.sample.id, topicName: Topic.sample.name)
            .sampleDataContainer()
    }
}
