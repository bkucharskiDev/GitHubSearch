//
//  RepositoriesClient+Live.swift
//  GitHubSearch
//
//  Created by Bartosz Kucharski on 06/03/2021.
//

import Foundation
import Dependencies

extension DependencyValues {
  var repositoriesClient: RepositoriesClient {
    get { self[RepositoriesClient.self] }
    set { self[RepositoriesClient.self] = newValue }
  }
}

extension RepositoriesClient: DependencyKey {
    
    /// Production version of RepositoriesClient.
    static let liveValue = RepositoriesClient { phrase in
        /// SearchForRepositoriesId acts as unique id (hash value). It could be plain string also.
        /// However it adds extra protection, as it's almost impossible to duplicate it.
        struct SearchForRepositoriesId: Hashable {}
        
        return URLSession.shared
            .dataTaskPublisher(for: getRepositoriesURLRequest(phrase: phrase))
            .eraseToEffect()
            .cancellable(id: SearchForRepositoriesId(), cancelInFlight: true)
            .map(\.data)
            .decode(type: RepositoriesResponse.self, decoder: JSONDecoder())
            .compactMap { $0.repositories?.map { $0.toRepository } }
            .catchToEffect()
    }
    
}

private extension RepositoriesClient {

  static func getRepositoriesURLRequest(phrase: String) -> URLRequest {
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = "api.github.com"
    urlComponents.path = "/search/repositories"
    urlComponents.queryItems = [.init(name: "q", value: phrase)]

    var urlRequest = URLRequest(url: urlComponents.url!)
    urlRequest.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "accept")

    return urlRequest
  }
}
