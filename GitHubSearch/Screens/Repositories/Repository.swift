//
//  Repository.swift
//  GitHubSearch
//
//  Created by Bartosz Kucharski on 06/03/2021.
//

import Foundation

struct Repository: Equatable, Identifiable {

    var id: URL { url }
    let name: String
    let description: String?
    let url: URL
    let imageURL: URL
    
    
}
