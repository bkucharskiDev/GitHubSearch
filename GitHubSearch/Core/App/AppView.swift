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
    WithViewStore(store.scope(state: \.isDemoOngoing)) { viewStore in
      ZStack(alignment: .bottomTrailing) {
        RepositoriesView(store: self.store.scope(
          state: \AppReducer.State.repositoriesState,
          action: AppReducer.Action.repositories
        ))
        Button("Demo") {
          viewStore.send(.demoButtonTapped)
        }
        .disabled(viewStore.state)
        .padding()
        .foregroundColor(Color.white)
        .font(.title)
        .background { viewStore.state ? Color.gray : Color.blue }
        .cornerRadius(32)
        .padding(.trailing)
        .padding(.bottom)
      }
    }
  }
}

struct AppReducer: ReducerProtocol {

  struct State: Equatable {
    var isDemoOngoing = false
    var repositoriesState = RepositoriesReducer.State()
  }

  enum Action: Equatable {
    case repositories(RepositoriesReducer.Action)
    case demoButtonTapped
  }

  public var body: some ReducerProtocol<State, Action> {
    Scope(
      state: \State.repositoriesState,
      action: /Action.repositories
    ) {
      RepositoriesReducer()
    }
    LogReducer()
    DemoReducer()
  }

}
