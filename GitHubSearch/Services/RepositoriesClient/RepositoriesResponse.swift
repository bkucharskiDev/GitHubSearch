//
//  RepositoriesResponse.swift
//  GitHubSearch
//
//  Created by Bartosz Kucharski on 04/03/2021.
//

import Foundation

struct RepositoriesResponse: Codable {
    private enum CodingKeys: String, CodingKey {
        case repositories = "items"
    }
    
    let repositories: [Repository]?
}