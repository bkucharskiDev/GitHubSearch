//
//  Environment.swift
//  GitHubSearch
//
//  Created by Bartosz Kucharski on 06/03/2021.
//

import ComposableArchitecture

// This property should be used only by view factories to inject proper dependencies.
let Current = Environment(
    mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
    repositoriesClient: .live
)

/// To completely separate from backend we can use mocked instance of `Current` and comment out live instance.
/// It's shown here how it can be created.

//#if DEBUG
//let Current = Environment(
//    mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
//    repositoriesClient: .happyPathMock)
//)
//#endif


struct Environment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var repositoriesClient: RepositoriesClient
}
