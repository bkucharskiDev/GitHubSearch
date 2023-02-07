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

struct RepositoriesReducer: ReducerProtocol {
  struct State: Equatable {
    var urlToShow: URL?
    var isAlertPresented: Bool = false
    var isLoading: Bool = false
    var searchPhrase: String = ""
    var repositories: IdentifiedArrayOf<Repository> = []
  }

  enum Action: Equatable {
    case textProvided(String)
    case searchForRepositories
    case repositoryTapped(URL)
    case repositoriesFetched([Repository])
    case alertDismissed
    case webViewDismissed
    case error
  }

  @Dependency(\.mainQueue) var mainQueue
  @Dependency(\.repositoriesClient) var repositoriesClient

  func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
    case let .textProvided(text):
      guard state.searchPhrase != text else {
        return .none
      }
      state.searchPhrase = text
      /// TypingCompletionId acts as unique id (hash value). It could be plain string also.
      /// However it adds extra protection, as it's almost impossible to duplicate it.
      struct TypingCompletionId: Hashable {}

      return EffectTask(value: .searchForRepositories)
      // Debounce typing for 1 second.
        .debounce(id: TypingCompletionId(), for: 1, scheduler: mainQueue)
    case .searchForRepositories:
      state.isAlertPresented = false
      let phrase = state.searchPhrase
      guard !phrase.isEmpty else {
        return .none
      }
      state.isLoading = true

      return repositoriesClient.searchForRepositories(phrase)
        .flatMap { result -> EffectTask<RepositoriesReducer.Action> in
          switch result {
          case let .success(repositories):
            return EffectTask(value: .repositoriesFetched(repositories))
          case .failure:
            return EffectTask(value: .error)
          }
        }
        .receive(on: mainQueue)
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
      state.repositories = IdentifiedArray(uniqueElements: repositories)
      return .none
    case .alertDismissed:
      state.isAlertPresented = false
      return .none
    case .webViewDismissed:
      state.urlToShow = nil
      return .none
    }
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

  let store: StoreOf<RepositoriesReducer>
  @FocusState var isTextFieldFocused: Bool

  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack {
        TextField(
          "Search phrase",
          text: viewStore.binding(
            get: \.searchPhrase,
            send: RepositoriesReducer.Action.textProvided
          )
        )
        .focused($isTextFieldFocused)
        .padding(.horizontal)
        .padding(.top)
        if viewStore.state.isLoading {
          ActivityIndicator()
        }
        List {
          ForEach(viewStore.state.repositories) { repository in
            RepositoryView(repository: repository)
              .onTapGesture { viewStore.send(.repositoryTapped(repository.url)) }
          }
        }
      }
      .onAppear { self.isTextFieldFocused = true }
      .alert(isPresented: viewStore.binding(get: \.isAlertPresented,
                                            send: RepositoriesReducer.Action.alertDismissed)) {
        Alert(
          title: Text("Sorry, something went wrong."),
          primaryButton: .default(Text("Try again")) {
            viewStore.send(.searchForRepositories)
          },
          secondaryButton: .cancel { viewStore.send(.alertDismissed) }
        )
      }
      .sheet(isPresented: viewStore.binding(
        get: { $0.urlToShow != nil },
        send: RepositoriesReducer.Action.webViewDismissed
      )) { WebView(url: viewStore.urlToShow!) }
    }
  }

}

struct RepositoriesView_Previews: PreviewProvider {

  static var previews: some View {
    RepositoriesView(
      store: .init(initialState: .init(), reducer: RepositoriesReducer())
    )
  }

}
