import SwiftUI

struct TopicDetailView: View
{
    let topicID: UUID
    let topicName: String

    var body: some View
    {
        ScrollView
        {
            VStack(alignment: .leading, spacing: 24)
            {
                VStack(alignment: .leading, spacing: 12)
                {
                    Text("Focus session")
                        .font(.headline)

                    NavigationLink(value: TopicDetailRoute.timerView)
                    {
                        ActionCard(
                            title: "Start focus session",
                            subtitle: "Track a new study session for this topic",
                            systemImage: "play.fill",
                            showsChevron: true
                        )
                    }
                    .buttonStyle(.plain)
                }

                VStack(alignment: .leading, spacing: 12)
                {
                    Text("Study History")
                        .font(.headline)

                    NavigationLink(value: TopicDetailRoute.progressPlanView)
                    {
                        ProgressPlanOverviewCard(
                            topicID: topicID,
                            topicName: topicName)
                    }
                    .buttonStyle(.plain)

                    NavigationLink(value: TopicDetailRoute.timesView)
                    {
                        TopicCard(
                            systemImage: "clock.fill",
                            title: "Study time",
                            subtitle: "See daily and total accumulated study time."
                        )
                    }
                    .buttonStyle(.plain)
                    
                    NavigationLink(value: TopicDetailRoute.streakView)
                    {
                        TopicCard(
                            systemImage: "flame.fill",
                            title: "Streak",
                            subtitle: "Check your current and longest study streak."
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink(value: TopicDetailRoute.calendarView)
                    {
                        TopicCard(
                            systemImage: "calendar",
                            title: "Calendar",
                            subtitle: "See if you are on track to meet your goals."
                        )
                    }
                    .buttonStyle(.plain)
                    
                    NavigationLink(value: TopicDetailRoute.goalView)
                    {
                        TopicCard(
                            systemImage: "target",
                            title: "Change goal",
                            subtitle: "Change the goal of your topic."
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .navigationTitle(topicName)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: TopicDetailRoute.self)
        { route in
            switch route
            {
            case .timerView:
                TimerView(topicID: topicID, topicName: topicName)
            case .streakView:
                StreakView(topicID: topicID, topicName: topicName)
            case .timesView:
                TimesView(topicID: topicID, topicName: topicName)
            case .calendarView:
                CalendarView(topicID: topicID, topicName: topicName)
            case .goalView:
                GoalView(topicID: topicID, topicName: topicName)
            case .progressPlanView:
                ProgressPlanChartView(topicID: topicID, topicName: topicName)
            }
        }
    }
}

private enum TopicDetailRoute: Hashable
{
    case timerView
    case streakView
    case timesView
    case calendarView
    case goalView
    case progressPlanView
}

#Preview
{
    NavigationStack
    {
        TopicDetailView(topicID: UUID(), topicName: "Mathematics")
    }
}
