//
//  RepositoriesClient+Mock.swift
//  GitHubSearch
//
//  Created by Bartosz Kucharski on 06/03/2021.
//

import ComposableArchitecture

extension RepositoriesClient {
    
    #if DEBUG
    /// Creates mock instance of RepositoriesClient.
    /// - Parameter searchForRepositories: mocked closure for searching for repositories.
    /// - Returns: mocked RepositoriesClient.
    static func mock(searchForRepositories: @escaping (_ phrase: String) -> Effect<Result<[Repository], Error>, Never>) -> Self {
        Self(searchForRepositories: searchForRepositories)
    }
    
    static let happyPathMockUsing: (_ repositories: [Repository]) -> Self = { repositories in
        .mock(searchForRepositories: { _ in Effect(value: .success(repositories)) })
    }
    
    static let happyPathMock: Self = {
        let mockedRepository = Repository(name: "swift",
                                          description: "The Swift Programming Language",
                                          url: URL(string: "https://github.com/apple/swift")!,
                                          imageURL: URL(string: "https://avatars.githubusercontent.com/u/10639145?v=4")!)
        return .happyPathMockUsing([mockedRepository])
    }()
    
    static let emptyMock: Self = .happyPathMockUsing([])
    
    static let failureMock: Self = .mock(searchForRepositories: { _ in Effect(value: .failure(NSError())) })
    #endif
    
}
