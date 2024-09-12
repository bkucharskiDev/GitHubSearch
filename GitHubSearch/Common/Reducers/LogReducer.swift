//
//  LogReducer.swift
//  GitHubSearch
//
//  Created by Bartosz Kucharski on 07/02/2023.
//

import ComposableArchitecture

@Reducer
struct LogReducer {

    // We are able to register every action that is needed. Here is just a simple example.
    var body: some Reducer<AppReducer.State, AppReducer.Action> {
        Reduce { _, action in
        #if DEBUG
            print("Registered action: \(action)")
        #endif
            return .none
        }
    }

}
