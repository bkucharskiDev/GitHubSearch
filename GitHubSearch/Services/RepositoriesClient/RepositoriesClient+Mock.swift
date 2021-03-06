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
    
    static let emptyMock: Self = .mock(searchForRepositories: { _ in Effect(value: .success([])) })
    
    static let happyPathMockUsing: (_ repositories: [Repository]) -> Self = { repositories in
        .mock(searchForRepositories: { _ in Effect(value: .success(repositories)) })
    }
    
    static let happyPathMock: Self = {
        let mockedRepository = Repository(name: "swift", urlString: "https://github.com/apple/swift")
        return .happyPathMockUsing([mockedRepository])
    }()
    
    static let failureMock: Self = .mock(searchForRepositories: { _ in Effect(value: .failure(NSError())) })
    #endif
    
}