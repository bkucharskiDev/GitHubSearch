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
    RepositoriesView(store: self.store.scope(
      state: \AppReducer.State.repositoriesState,
      action: AppReducer.Action.repositories
    ))
  }
}

struct AppReducer: ReducerProtocol {

  struct State: Equatable {
    var repositoriesState = RepositoriesReducer.State()
  }

  enum Action: Equatable {
    case repositories(RepositoriesReducer.Action)
  }

  public var body: some ReducerProtocol<State, Action> {
    Scope(
      state: \State.repositoriesState,
      action: /Action.repositories
    ) {
      RepositoriesReducer()
    }
  }

}
