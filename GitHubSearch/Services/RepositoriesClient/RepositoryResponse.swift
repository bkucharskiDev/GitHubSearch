//
//  Repository.swift
//  GitHubSearch
//
//  Created by Bartosz Kucharski on 04/03/2021.
//

import Foundation

struct RepositoryResponse: Decodable {
    
    struct OwnerResponse: Decodable {
        
        enum CodingKeys: String, CodingKey {
            case avatarUrl = "avatar_url"
        }
        
        var avatarUrl: String
        
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case urlString = "html_url"
        case description
        case owner
    }
    
    let name: String
    let urlString: String
    let description: String?
    let owner: OwnerResponse
    
}

extension RepositoryResponse {
        
    var toRepository: Repository {
        .init(name: name,
              description: description,
              url: URL(string: urlString)!,
              imageURL: URL(string: owner.avatarUrl)!)
    }
    
}
