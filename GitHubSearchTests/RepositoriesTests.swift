//
//  RepositoriesTests.swift
//  GitHubSearchTests
//
//  Created by Bartosz Kucharski on 04/03/2021.
//

import Combine
import ComposableArchitecture
import XCTest

@testable import GitHubSearch

class RepositoriesTests: XCTestCase {
    let scheduler = DispatchQueue.testScheduler
    
    func testLoading() {
        let store = TestStore(
            initialState: RepositoriesView.ViewState(),
            reducer: repositoriesReducer,
            environment: RepositoriesViewEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                repositoriesClient: .emptyMock
            )
        )
        
        store.assert(
            .send(.textProvided("swift")) { $0.searchPhrase = "swift" },
            .do { self.scheduler.advance(by: 1.0) },
            .receive(.searchForRepositories) { $0.isLoading = true } ,
            .receive(.repositoriesFetched([])) {
                $0.isLoading = false
                $0.repositories = []
            }
        )
    }
    
    func testSearchingDebounce() {
        let store = TestStore(
            initialState: RepositoriesView.ViewState(),
            reducer: repositoriesReducer,
            environment: RepositoriesViewEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                repositoriesClient: .emptyMock
            )
        )
        
        store.assert(
            .send(.textProvided("a")) { $0.searchPhrase = "a" },
            .do { self.scheduler.advance(by: 0.5) },
            .send(.textProvided("abc")) { $0.searchPhrase = "abc" },
            .do { self.scheduler.advance(by: 0.9) },
            .send(.textProvided("xdxd")) { $0.searchPhrase = "xdxd" },
            .do { self.scheduler.advance(by: 1.1) },
            .receive(.searchForRepositories) { $0.isLoading = true } ,
            .receive(.repositoriesFetched([])) {
                $0.isLoading = false
                $0.repositories = []
            }
        )
    }
    
    func testErrorAlertAppear() {
        let store = TestStore(
            initialState: RepositoriesView.ViewState(),
            reducer: repositoriesReducer,
            environment: RepositoriesViewEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                repositoriesClient: .failureMock
            )
        )
        
        store.assert(
            .send(.textProvided("swift")) { $0.searchPhrase = "swift" },
            .do { self.scheduler.advance(by: 1.0) },
            .receive(.searchForRepositories) { $0.isLoading = true } ,
            .receive(.error) {
                $0.isLoading = false
                $0.isAlertPresented = true
            }
        )
    }
    
    func testErrorAlertDismissCancel() {
        let store = TestStore(
            initialState: RepositoriesView.ViewState(),
            reducer: repositoriesReducer,
            environment: RepositoriesViewEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                repositoriesClient: .failureMock
            )
        )
        
        store.assert(
            .send(.textProvided("swift")) { $0.searchPhrase = "swift" },
            .do { self.scheduler.advance(by: 1.0) },
            .receive(.searchForRepositories) { $0.isLoading = true } ,
            .receive(.error) {
                $0.isLoading = false
                $0.isAlertPresented = true
            },
            .send(.alertDismissed) { $0.isAlertPresented = false }
        )
    }
    
    func testErrorAlertDismissTryAgain() {
        let store = TestStore(
            initialState: RepositoriesView.ViewState(),
            reducer: repositoriesReducer,
            environment: RepositoriesViewEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                repositoriesClient: .failureMock
            )
        )
        
        store.assert(
            .send(.textProvided("swift")) { $0.searchPhrase = "swift" },
            .do { self.scheduler.advance(by: 1.0) },
            .receive(.searchForRepositories) { $0.isLoading = true } ,
            .receive(.error) {
                $0.isLoading = false
                $0.isAlertPresented = true
            },
            .send(.searchForRepositories) {
                $0.isLoading = true
                $0.isAlertPresented = false
            },
            .do { self.scheduler.advance() },
            .receive(.error) {
                $0.isLoading = false
                $0.isAlertPresented = true
            }
        )
    }
    
    func testTapRepository() {
        let mockRepository = Repository(name: "Foo",
                                        description: nil,
                                        url: URL(string: "http://foo")!,
                                        imageURL: URL(string: "http://foo")!)
        let store = TestStore(
            initialState: RepositoriesView.ViewState(),
            reducer: repositoriesReducer,
            environment: RepositoriesViewEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                repositoriesClient: .happyPathMockUsing([mockRepository])
            )
        )
        
        store.assert(
            .send(.textProvided("swift")) { $0.searchPhrase = "swift" },
            .do { self.scheduler.advance(by: 1.0) },
            .receive(.searchForRepositories) { $0.isLoading = true },
            .receive(.repositoriesFetched([mockRepository])) {
                $0.isLoading = false
                $0.repositories = [mockRepository]
            },
            .send(.repositoryTapped(mockRepository.url)) { $0.urlToShow = mockRepository.url }
        )
    }
    
    func testDismissRepository() {
        let mockRepository = Repository(name: "Foo",
                                        description: nil,
                                        url: URL(string: "http://foo")!,
                                        imageURL: URL(string: "http://foo")!)
        let store = TestStore(
            initialState: RepositoriesView.ViewState(),
            reducer: repositoriesReducer,
            environment: RepositoriesViewEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                repositoriesClient: .happyPathMockUsing([mockRepository])
            )
        )
        
        store.assert(
            .send(.textProvided("swift")) { $0.searchPhrase = "swift" },
            .do { self.scheduler.advance(by: 1.0) },
            .receive(.searchForRepositories) { $0.isLoading = true },
            .receive(.repositoriesFetched([mockRepository])) {
                $0.isLoading = false
                $0.repositories = [mockRepository]
            },
            .send(.repositoryTapped(mockRepository.url)) { $0.urlToShow = mockRepository.url },
            .send(.webViewDismissed) { $0.urlToShow = nil }
        )
    }
    
    func testUnhappyAndHappyPath() {
        let mockRepository = Repository(name: "Foo",
                                        description: nil,
                                        url: URL(string: "http://foo")!,
                                        imageURL: URL(string: "http://foo")!)
        let store = TestStore(
            initialState: RepositoriesView.ViewState(),
            reducer: repositoriesReducer,
            environment: RepositoriesViewEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                repositoriesClient: .failureMock
            )
        )
        
        store.assert(
            .send(.textProvided("swift")) { $0.searchPhrase = "swift" },
            .do { self.scheduler.advance(by: 1.0) },
            .receive(.searchForRepositories) { $0.isLoading = true },
            .receive(.error) {
                $0.isLoading = false
                $0.isAlertPresented = true
            },
            .environment { environment in
                environment.repositoriesClient = .happyPathMockUsing([mockRepository])
            },
            .send(.searchForRepositories) {
                $0.isLoading = true
                $0.isAlertPresented = false
            },
            .do { self.scheduler.advance() },
            .receive(.repositoriesFetched([mockRepository])) {
                $0.isLoading = false
                $0.repositories = [mockRepository]
            }
        )
    }
    
    
}
