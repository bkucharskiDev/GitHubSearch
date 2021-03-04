//
//  GitHubSearchApp.swift
//  GitHubSearch
//
//  Created by Bartosz Kucharski on 03/03/2021.
//

import SwiftUI
import ComposableArchitecture
import Combine

@main
struct GitHubSearchApp: App {
    var body: some Scene {
        WindowGroup {
            RepositoriesView(store: Store(
                initialState: RepositoriesView.ViewState(),
                reducer: repositoriesReducer,
                environment: RepositoriesViewEnvironment(mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                                                         repositoriesClient: RepositoriesClient.live)
            )
            )
        }
    }
}
