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
    
    var searchForRepositories: (_ phrase: String) -> Effect<Result<[Repository], Error>, Never>
    
    init(searchForRepositories: @escaping (_ phrase: String) -> Effect<Result<[Repository], Error>, Never>) {
        self.searchForRepositories = searchForRepositories
    }
}

extension RepositoriesClient {
    
    static let live = RepositoriesClient { phrase in
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
    
    #if DEBUG
    static func mock(searchForRepositories: @escaping (_ phrase: String) -> Effect<Result<[Repository], Error>, Never>) -> Self {
        Self(searchForRepositories: searchForRepositories)
    }
    #endif
    
}
