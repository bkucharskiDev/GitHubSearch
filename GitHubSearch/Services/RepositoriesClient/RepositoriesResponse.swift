//
//  RepositoriesResponse.swift
//  GitHubSearch
//
//  Created by Bartosz Kucharski on 04/03/2021.
//

struct RepositoriesResponse: Decodable {
  
  private enum CodingKeys: String, CodingKey {
    case repositories = "items"
  }

  let repositories: [RepositoryResponse]?

}
