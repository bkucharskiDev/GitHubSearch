//
//  RepositoriesView.swift
//  GitHubSearch
//
//  Created by Bartosz Kucharski on 03/03/2021.
//

import SwiftUI
import ComposableArchitecture
import Combine

enum RepositoriesViewAction {
    case textProvided(String)
    case searchForRepositories
    case repositoryTapped(URL)
    case repositoriesFetched([Repository])
    case alertDismissed
    case error
}

struct RepositoriesViewEnvironment {
    
    var searchForRepositories: (_ phrase: String) -> Future<[Repository], Error>
    
}

let repositoriesReducer = Reducer<RepositoriesView.ViewState, RepositoriesViewAction, RepositoriesViewEnvironment> { state, action, environment in
    switch action {
    case let .textProvided(text):
        state.searchPhrase = text
        struct TypingCompletionId: Hashable {}
        return Effect(value: .searchForRepositories)
            // Debounce typing for 1 second.
            .debounce(id: TypingCompletionId(), for: 1, scheduler: DispatchQueue.main)
    case .searchForRepositories:
        state.isAlertPresented = false
        return environment.searchForRepositories(state.searchPhrase)
            .subscribe(on: DispatchQueue.main)
            .catchToEffect()
            .flatMap { result -> Effect<RepositoriesViewAction, Never> in
                switch result {
                case let .success(repositories):
                    return Effect(value: .repositoriesFetched(repositories))
                case .failure:
                    return Effect(value: .error)
                }
            }
            .eraseToEffect()
    case let .repositoryTapped(url):
        state.urlToShow = url
        return .none
    case .error:
        state.isAlertPresented = true
        return .none
    case let .repositoriesFetched(repositories):
        state.repositories = IdentifiedArray(repositories)
        return .none
    case .alertDismissed:
        state.isAlertPresented = false
        return .none
    }
}

struct RepositoriesView: View {
    
    struct ViewState: Equatable {
        var urlToShow: URL?
        var isAlertPresented: Bool = false
        var isLoading: Bool = false
        var searchPhrase: String = ""
        var repositories: IdentifiedArrayOf<Repository> = []
    }
    
    let store: Store<RepositoriesView.ViewState, RepositoriesViewAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                TextField(
                    "Search phrase",
                    text: viewStore.binding(
                        get: \.searchPhrase,
                        send: RepositoriesViewAction.textProvided
                    )
                )
                .padding()
                
                List {
                    ForEach(viewStore.state.repositories) { repository in
                        Text(repository.url.absoluteString)
                            .onTapGesture {
                                viewStore.send(.repositoryTapped(repository.url))
                            }
                    }
                }
            }
            .alert(isPresented: viewStore.binding(get: \.isAlertPresented,
                                                  send: RepositoriesViewAction.alertDismissed)) {
                Alert(title: Text("Sorry, something went wrong."))
            }
        }
    }
}

struct RepositoriesView_Previews: PreviewProvider {
    static var previews: some View {
        RepositoriesView(store: Store(initialState: RepositoriesView.ViewState(),
                                 reducer: repositoriesReducer,
                                 environment: RepositoriesViewEnvironment(searchForRepositories: { _ in Future { _ in } })))
    }
}