//
//  DemoReducer.swift
//  GitHubSearch
//
//  Created by Bartosz Kucharski on 07/02/2023.
//

import ComposableArchitecture
import Dispatch

struct DemoReducer: ReducerProtocol {

  struct State: Equatable {
    var isDemoOngoing = false
  }

  // Showcase for little Demo functionality
  func reduce(into state: inout State, action: AppReducer.Action) -> EffectTask<AppReducer.Action> {
    switch action {
    case .demoButtonTapped:
      state.isDemoOngoing = true
      return .run { send in
        var textToSend = ""
        try await "Swift".asyncForEach { char in
          textToSend.append(String(char))
          await send(.repositories(.textProvided(textToSend)))
          try await Task.sleep(nanoseconds: NSEC_PER_SEC / 2)
        }
      }
    case let .repositories(.repositoriesFetched(repositories)):
      guard let firstRepo = repositories.first else {
        state.isDemoOngoing = false
        return .none
      }
      return .run { send in
        try await Task.sleep(nanoseconds: NSEC_PER_SEC)
        return await send(.repositories(.repositoryTapped(firstRepo.url)))
      }
    case .repositories(.repositoryTapped):
      state.isDemoOngoing = false
    case .repositories(.error):
      state.isDemoOngoing = false
    default:
      return .none
    }
    return .none
  }

}

private extension Sequence {
  func asyncForEach(
      _ operation: (Element) async throws -> Void
  ) async rethrows {
      for element in self {
          try await operation(element)
      }
  }
}
