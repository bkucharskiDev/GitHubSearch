//
//  Repository.swift
//  GitHubSearch
//
//  Created by Bartosz Kucharski on 04/03/2021.
//

import Foundation

struct Repository: Equatable, Identifiable, Codable {
    
    enum CodingKeys: String, CodingKey {
        case name
        case urlString = "url"
    }
    
    var id: String { urlString }
    var url: URL { URL(string: urlString)!  }
    
    let name: String
    let urlString: String
}
