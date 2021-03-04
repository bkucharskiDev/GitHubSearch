//
//  RepositoriesClient.swift
//  GitHubSearch
//
//  Created by Bartosz Kucharski on 04/03/2021.
//

import Foundation
import Combine
import ComposableArchitecture

protocol RepositoriesClientProtocol {
    /// Searches repositories.
    /// - Parameter phrase: search phrase.
    func searchForRepositories(_ phrase: String) -> Effect<Result<[Repository], Error>, Never>
}

struct RepositoriesClient: RepositoriesClientProtocol {
    
    func searchForRepositories(_ phrase: String) -> Effect<Result<[Repository], Error>, Never> {
        /// SearchForRepositoriesId acts as unique id (hash value). It could be plain string also.
        /// However it adds extra protection, as it's almost impossible to duplicate it.
        struct SearchForRepositoriesId: Hashable {}
        var urlRequest = URLRequest(url: URL(string: "https://api.github.com/search/repositories?q=\(phrase)")!)
        urlRequest.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "accept")
        
        return URLSession.shared
            .dataTaskPublisher(for: urlRequest)
            .eraseToEffect()
            .cancellable(id: SearchForRepositoriesId(), cancelInFlight: true)
            .map(\.data)
            .decode(type: RepositoriesResponse.self, decoder: JSONDecoder())
            .compactMap(\.repositories)
            .catchToEffect()
    }
    
}
