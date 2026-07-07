//
//  ContentView.swift
//  Goals
//
//  Created by Adolfo Gerard Montilla Gonzalez on 07-07-26.
//

import SwiftUI

struct ContentView: View
{
    var body: some View
    {
        NavigationStack
        {
            ScrollView
            {
                VStack(alignment: .leading, spacing: 20)
                {
                    Text("Summary")
                        .font(.largeTitle.bold())
                        .padding(.top, 8)

                    Text("Your only job: be a bit better than yesterday.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    VStack(spacing: 12)
                    {
                        NavigationLink(value: NavigationOptions.topics)
                        {
                            SummaryCard(
                                title: "Topics",
                                subtitle: "Manage what you study and start focus sessions.",
                                systemImage: "list.bullet.rectangle",
                                showsChevron: true
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink(value: NavigationOptions.achievements)
                        {
                            SummaryCard(
                                title: "Achievements",
                                subtitle: "Review your progress and completed milestones.",
                                systemImage: "medal.fill",
                                showsChevron: true
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationDestination(for: NavigationOptions.self)
            { page in
                switch page
                {
                case .topics:
                    TopicListView()
                case .achievements:
                    EmptyView()
                }
            }
        }
    }
}

#Preview
{
    ContentView()
        .sampleDataContainer()
}

