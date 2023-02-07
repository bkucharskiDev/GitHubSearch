//
//  AppView.swift
//  GitHubSearch
//
//  Created by Bartosz Kucharski on 06/02/2023.
//

import Foundation
import ComposableArchitecture
import SwiftUI

struct AppView: View {
  let store: StoreOf<AppReducer>

  var body: some View {
    WithViewStore(store.scope(state: \.demoState)) { viewStore in
      ZStack(alignment: .bottomTrailing) {
        RepositoriesView(store: self.store.scope(
          state: \AppReducer.State.repositoriesState,
          action: AppReducer.Action.repositories
        ))
        Button("Demo") {
          viewStore.send(.demoButtonTapped)
        }
        .disabled(viewStore.state?.isDemoOngoing ?? false)
        .padding()
        .foregroundColor(Color.white)
        .font(.title)
        .background { viewStore.state?.isDemoOngoing == true ? Color.gray : Color.blue }
        .cornerRadius(32)
        .padding(.trailing)
        .padding(.bottom)
      }
    }
  }
}

struct AppReducer: ReducerProtocol {

  struct State: Equatable {
    var demoState: DemoReducer.State?
    var repositoriesState = RepositoriesReducer.State()
  }

  enum Action: Equatable {
    case repositories(RepositoriesReducer.Action)
    case demoButtonTapped
  }

  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .demoButtonTapped:
        state.demoState = .init()
      case .repositories(.repositoryTapped):
        state.demoState = nil
      default:
        return .none
      }
      return .none
    }
    Scope(
      state: \State.repositoriesState,
      action: /Action.repositories
    ) {
      RepositoriesReducer()
    }
    .ifLet(\.demoState, action: /Action.self) {
      DemoReducer()
    }
    LogReducer()

  }

}
