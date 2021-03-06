//
//  RepositoriesClient+Live.swift
//  GitHubSearch
//
//  Created by Bartosz Kucharski on 06/03/2021.
//

import Foundation

extension RepositoriesClient {
    
    /// Production version of RepositoriesClient.
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
            .compactMap { $0.repositories?.map { $0.toRepository } }
            .catchToEffect()
    }
    
}
