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

@MainActor
class RepositoriesTests: XCTestCase {
  let mainQueue = DispatchQueue.test

  func testLoading() async throws {
    let store = TestStore(
      initialState: RepositoriesReducer.State(),
      reducer: RepositoriesReducer()
    )
    store.dependencies.repositoriesClient = .emptyMock
    store.dependencies.mainQueue = self.mainQueue.eraseToAnyScheduler()

    await store.send(.textProvided("swift")) { $0.searchPhrase = "swift" }
    await self.mainQueue.advance(by: 1.0)
    await store.receive(.searchForRepositories) { $0.isLoading = true }
    await store.receive(.repositoriesFetched([])) {
      $0.isLoading = false
      $0.repositories = []
    }
  }

  func testSearchingDebounce() async throws {
    let store = TestStore(
      initialState: RepositoriesReducer.State(),
      reducer: RepositoriesReducer()
    )
    store.dependencies.repositoriesClient = .emptyMock
    store.dependencies.mainQueue = self.mainQueue.eraseToAnyScheduler()

    await store.send(.textProvided("a")) { $0.searchPhrase = "a" }
    await self.mainQueue.advance(by: 0.5)
    await store.send(.textProvided("abc")) { $0.searchPhrase = "abc" }
    await self.mainQueue.advance(by: 0.9)
    await store.send(.textProvided("xdxd")) { $0.searchPhrase = "xdxd" }
    await self.mainQueue.advance(by: 1.1)
    await store.receive(.searchForRepositories) { $0.isLoading = true }
    await store.receive(.repositoriesFetched([])) {
      $0.isLoading = false
      $0.repositories = []
    }
  }

  func testErrorAlertAppear() async throws {
    let store = TestStore(
      initialState: RepositoriesReducer.State(),
      reducer: RepositoriesReducer()
    )
    store.dependencies.repositoriesClient = .failureMock
    store.dependencies.mainQueue = self.mainQueue.eraseToAnyScheduler()

    await store.send(.textProvided("swift")) { $0.searchPhrase = "swift" }
    await self.mainQueue.advance(by: 1.0)
    await store.receive(.searchForRepositories) { $0.isLoading = true }
    await store.receive(.error) {
      $0.isLoading = false
      $0.isAlertPresented = true
    }
  }

    func testErrorAlertDismissCancel() async throws {
      let store = TestStore(
        initialState: RepositoriesReducer.State(),
        reducer: RepositoriesReducer()
      )
      store.dependencies.repositoriesClient = .failureMock
      store.dependencies.mainQueue = self.mainQueue.eraseToAnyScheduler()

      await store.send(.textProvided("swift")) { $0.searchPhrase = "swift" }
      await self.mainQueue.advance(by: 1.0)
      await store.receive(.searchForRepositories) { $0.isLoading = true }
      await store.receive(.error) {
        $0.isLoading = false
        $0.isAlertPresented = true
      }
      await store.send(.alertDismissed) { $0.isAlertPresented = false }
    }

    func testErrorAlertDismissTryAgain() async throws {
      let store = TestStore(
        initialState: RepositoriesReducer.State(),
        reducer: RepositoriesReducer()
      )
      store.dependencies.repositoriesClient = .failureMock
      store.dependencies.mainQueue = self.mainQueue.eraseToAnyScheduler()

      await store.send(.textProvided("swift")) { $0.searchPhrase = "swift" }
      await self.mainQueue.advance(by: 1.0)
      await store.receive(.searchForRepositories) { $0.isLoading = true }
      await store.receive(.error) {
        $0.isLoading = false
        $0.isAlertPresented = true
      }
      await store.send(.searchForRepositories) {
        $0.isLoading = true
        $0.isAlertPresented = false
      }
      await self.mainQueue.advance()
      await store.receive(.error) {
        $0.isLoading = false
        $0.isAlertPresented = true
      }
    }

  func testTapRepository() async throws {
    let mockRepository = Repository(
      name: "Foo",
      description: nil,
      url: URL(string: "http://foo")!,
      imageURL: URL(string: "http://foo")!
    )

    let store = TestStore(
      initialState: RepositoriesReducer.State(),
      reducer: RepositoriesReducer()
    )
    store.dependencies.repositoriesClient = .happyPathMockUsing([mockRepository])
    store.dependencies.mainQueue = self.mainQueue.eraseToAnyScheduler()

    await store.send(.textProvided("swift")) { $0.searchPhrase = "swift" }
    await self.mainQueue.advance(by: 1.0)
    await store.receive(.searchForRepositories) { $0.isLoading = true }
    await store.receive(.repositoriesFetched([mockRepository])) {
      $0.isLoading = false
      $0.repositories = [mockRepository]
    }
    await store.send(.repositoryTapped(mockRepository.url)) { $0.urlToShow = mockRepository.url }
  }

  func testDismissRepository() async throws {
    let mockRepository = Repository(
      name: "Foo",
      description: nil,
      url: URL(string: "http://foo")!,
      imageURL: URL(string: "http://foo")!
    )

    let store = TestStore(
      initialState: RepositoriesReducer.State(),
      reducer: RepositoriesReducer()
    )
    store.dependencies.repositoriesClient = .happyPathMockUsing([mockRepository])
    store.dependencies.mainQueue = self.mainQueue.eraseToAnyScheduler()

    await store.send(.textProvided("swift")) { $0.searchPhrase = "swift" }
    await self.mainQueue.advance(by: 1.0)
    await store.receive(.searchForRepositories) { $0.isLoading = true }
    await store.receive(.repositoriesFetched([mockRepository])) {
      $0.isLoading = false
      $0.repositories = [mockRepository]
    }
    await store.send(.repositoryTapped(mockRepository.url)) { $0.urlToShow = mockRepository.url }
    await store.send(.webViewDismissed) { $0.urlToShow = nil }
  }

  func testUnhappyAndHappyPath() async throws {
    let mockRepository = Repository(
      name: "Foo",
      description: nil,
      url: URL(string: "http://foo")!,
      imageURL: URL(string: "http://foo")!
    )
    let store = TestStore(
      initialState: RepositoriesReducer.State(),
      reducer: RepositoriesReducer()
    )
    store.dependencies.repositoriesClient = .failureMock
    store.dependencies.mainQueue = self.mainQueue.eraseToAnyScheduler()

    await store.send(.textProvided("swift")) { $0.searchPhrase = "swift" }
    await self.mainQueue.advance(by: 1.0)
    await store.receive(.searchForRepositories) { $0.isLoading = true }
    await store.receive(.error) {
      $0.isLoading = false
      $0.isAlertPresented = true
    }
    store.dependencies.repositoriesClient = .happyPathMockUsing([mockRepository])
    await store.send(.searchForRepositories) {
      $0.isLoading = true
      $0.isAlertPresented = false
    }
    await self.mainQueue.advance()
    await store.receive(.repositoriesFetched([mockRepository])) {
      $0.isLoading = false
      $0.repositories = [mockRepository]
    }
  }
    
    
}
