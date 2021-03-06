//
//  ViewFactory+Repositories.swift
//  GitHubSearch
//
//  Created by Bartosz Kucharski on 06/03/2021.
//

import SwiftUI
import ComposableArchitecture

extension ViewFactory {
    
    enum Repositories {
        /// Creates and returns repositories view.
        /// - Returns: repositories view.
        static func buildRepositoriesView() -> RepositoriesView {
            RepositoriesView(store: Store(
                initialState: RepositoriesView.ViewState(),
                reducer: repositoriesReducer,
                environment: RepositoriesViewEnvironment(mainQueue: Current.mainQueue,
                                                         repositoriesClient: Current.repositoriesClient))
            )
        }
        
        /// Creates and returns single repository view.
        /// - Parameter repository: repository.
        /// - Returns: repository view.
        static func buildRepositoryView(_ repository: Repository) -> RepositoryView {
            RepositoryView(repository: repository)
        }
    }
    
}
