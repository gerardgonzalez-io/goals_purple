//
//  NavigationOptions.swift
//  Goals_Playing
//
//  Created by Adolfo Gerard Montilla Gonzalez on 25-05-26.
//

import Foundation

/// An enumeration of navigation options in the app.
enum NavigationOptions: Equatable, Hashable, Identifiable
{
    /// A case that represents viewing the app's topics.
    case topics
    /// A case that represents viewing the app's achievements.
    case achievements
    
    static let mainPages: [NavigationOptions] = [.topics, .achievements]
    
    var id: String
    {
        switch self
        {
        case .topics: return "Topics"
        case .achievements: return "Achievements"
        }
    }

    var name: String
    {
        switch self
        {
        case .topics: return "Topics"
        case .achievements: return "Achievements"
        }
    }

    var symbolName: String
    {
        switch self
        {
        case .topics: "book.closed.fill"
        case .achievements: "medal.fill"
        }
    }
}
