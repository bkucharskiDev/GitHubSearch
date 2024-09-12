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
        ZStack(alignment: .bottomTrailing) {
            RepositoriesView(store: self.store.scope(
                state: \.repositoriesState,
                action: \.repositories
            ))
            Button("Demo") { store.send(.demoButtonTapped) }
                .disabled(store.demoState?.isDemoOngoing ?? false)
                .padding()
                .foregroundColor(Color.white)
                .font(.title)
                .background { store.demoState?.isDemoOngoing == true ? Color.gray : Color.blue }
                .cornerRadius(32)
                .padding(.trailing)
                .padding(.bottom)
        }
    }
}

@Reducer
struct AppReducer {

    @ObservableState
    struct State: Equatable {
        var demoState: DemoReducer.State?
        var repositoriesState = RepositoriesReducer.State()
    }

    enum Action {
        case repositories(RepositoriesReducer.Action)
        case demoButtonTapped
    }

    public var body: some Reducer<State, Action> {
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
            state: \.repositoriesState,
            action: \.repositories) {
                RepositoriesReducer()
            }
//        Reduce { state, action in
//            switch action {
//            case let .repositories(action):
//                return RepositoriesReducer().reduce(into: &state.repositoriesState, action: action)
//                    .map({ AppReducer.Action.repositories($0) })
//            default:
//                return .none
//            }
//        }
        Scope(
            state: \.repositoriesState,
            action: \.repositories
        ) {
            RepositoriesReducer()
        }
        LogReducer()
            .ifLet(\.demoState, action: \.self) {
                DemoReducer()
            }

    }

}
