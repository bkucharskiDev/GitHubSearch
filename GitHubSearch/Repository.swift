//
//  Repository.swift
//  GitHubSearch
//
//  Created by Bartosz Kucharski on 04/03/2021.
//

import Foundation

struct Repository: Equatable, Identifiable {
    var id: URL { url }
    let url: URL
}
