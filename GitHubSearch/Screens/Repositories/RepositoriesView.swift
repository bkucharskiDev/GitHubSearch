//
//  RepositoriesView.swift
//  GitHubSearch
//
//  Created by Bartosz Kucharski on 03/03/2021.
//

import SwiftUI
import ComposableArchitecture
import Combine
import Kingfisher

enum RepositoriesViewAction: Equatable {
    
    case textProvided(String)
    case searchForRepositories
    case repositoryTapped(URL)
    case repositoriesFetched([Repository])
    case alertDismissed
    case webViewDismissed
    case error
    
}

struct RepositoriesViewEnvironment {
    
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var repositoriesClient: RepositoriesClient
    
}

let repositoriesReducer = Reducer<RepositoriesView.ViewState, RepositoriesViewAction, RepositoriesViewEnvironment> { state, action, environment in
    switch action {
    case let .textProvided(text):
        state.searchPhrase = text
        /// TypingCompletionId acts as unique id (hash value). It could be plain string also.
        /// However it adds extra protection, as it's almost impossible to duplicate it.
        struct TypingCompletionId: Hashable {}
        return Effect(value: .searchForRepositories)
            // Debounce typing for 1 second.
            .debounce(id: TypingCompletionId(), for: 1, scheduler: environment.mainQueue)
    case .searchForRepositories:
        state.isAlertPresented = false
        let phrase = state.searchPhrase
        guard !phrase.isEmpty else {
            return .none
        }
        state.isLoading = true
        
        return environment.repositoriesClient.searchForRepositories(phrase)
            .flatMap { result -> Effect<RepositoriesViewAction, Never> in
                switch result {
                case let .success(repositories):
                    return Effect(value: .repositoriesFetched(repositories))
                case .failure:
                    return Effect(value: .error)
                }
            }
            .receive(on: environment.mainQueue)
            .eraseToEffect()
    case let .repositoryTapped(url):
        state.urlToShow = url
        return .none
    case .error:
        state.isLoading = false
        state.isAlertPresented = true
        return .none
    case let .repositoriesFetched(repositories):
        state.isLoading = false
        state.repositories = IdentifiedArray(repositories)
        return .none
    case .alertDismissed:
        state.isAlertPresented = false
        return .none
    case .webViewDismissed:
        state.urlToShow = nil
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
                .padding(.horizontal)
                .padding(.top)
                if viewStore.state.isLoading {
                    ActivityIndicator()
                }
                List {
                    ForEach(viewStore.state.repositories) { repository in
                        VStack(alignment: .leading) {
                            HStack {
                                KFImage(repository.imageURL)
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                Text(repository.name)
                                    .bold()
                                    .padding(.leading, 5)
                            }
                            Text(repository.description ?? "")
                                .font(.body)
                                .italic()
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(3)
                        }
                        .padding(.vertical)
                        .onTapGesture { viewStore.send(.repositoryTapped(repository.url)) }
                    }
                }
            }
            .alert(isPresented: viewStore.binding(get: \.isAlertPresented,
                                                  send: RepositoriesViewAction.alertDismissed)) {
                Alert(
                    title: Text("Sorry, something went wrong."),
                    primaryButton: .default(Text("Try again")) {
                        viewStore.send(.searchForRepositories)
                    },
                    secondaryButton: .cancel { viewStore.send(.alertDismissed) }
                )
            }
            .sheet(isPresented: viewStore.binding(get: { $0.urlToShow != nil },
                                                  send: RepositoriesViewAction.webViewDismissed)) {
                WebView(url: viewStore.urlToShow!)
            }
        }
    }
    
}

struct RepositoriesView_Previews: PreviewProvider {
    
    static var previews: some View {
        RepositoriesView(
            store: Store(initialState: RepositoriesView.ViewState(),
                         reducer: repositoriesReducer,
                         environment: RepositoriesViewEnvironment(
                            mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                            repositoriesClient: RepositoriesClient.mock(
                                searchForRepositories: { _ in .none }
                            )
                         )
            )
        )
    }
    
}
