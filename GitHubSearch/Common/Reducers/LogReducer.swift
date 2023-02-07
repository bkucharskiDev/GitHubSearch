//
//  LogReducer.swift
//  GitHubSearch
//
//  Created by Bartosz Kucharski on 07/02/2023.
//

import ComposableArchitecture

struct LogReducer: ReducerProtocol {

  // We are able to register every action that is needed. Here is just a simple example.
  func reduce(into state: inout AppReducer.State, action: AppReducer.Action) -> EffectTask<AppReducer.Action> {
  #if DEBUG
    print("Registered action: \(action)")
  #endif
    return .none
  }

}
