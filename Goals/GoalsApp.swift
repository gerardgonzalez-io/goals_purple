//
//  GoalsApp.swift
//  Goals
//
//  Created by Adolfo Gerard Montilla Gonzalez on 07-07-26.
//

import SwiftData
import SwiftUI

@main
struct GoalsApp: App
{
    let dataContainer = DataContainer()

    var body: some Scene
    {
        WindowGroup
        {
            ContentView()
                .environment(dataContainer)
        }
        .modelContainer(dataContainer.modelContainer)
    }
}
