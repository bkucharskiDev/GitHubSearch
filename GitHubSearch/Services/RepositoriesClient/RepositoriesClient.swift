//
//  RepositoriesClient.swift
//  GitHubSearch
//
//  Created by Bartosz Kucharski on 04/03/2021.
//

import Foundation
import Combine
import ComposableArchitecture

struct RepositoriesClient {
    
    /// Closure for searching for repositories using search phrase.
    /// It returns effect with result with repositories or error.
    var searchForRepositories: (_ phrase: String) -> Effect<Result<[Repository], Error>, Never>
    
    /// Searches for repositories using provided search phrase.
    /// - Parameter searchForRepositories: closure that searches for repositories using search phrase.
    init(searchForRepositories: @escaping (_ phrase: String) -> Effect<Result<[Repository], Error>, Never>) {
        self.searchForRepositories = searchForRepositories
    }
    
}
