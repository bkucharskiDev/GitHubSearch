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

@Reducer
struct RepositoriesReducer {

    @ObservableState
    struct State: Equatable {
        var urlToShow: URL?
        var isAlertPresented: Bool = false
        var isLoading: Bool = false
        var searchPhrase: String = ""
        var repositories: IdentifiedArrayOf<Repository> = []
    }

    enum Action {
        case textProvided(String)
        case searchForRepositories
        case repositoryTapped(URL)
        case repositoriesResponse(Result<[Repository], Error>)
        case alertDismissed
        case webViewDismissed
    }

    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.repositoriesClient) var repositoriesClient

    func reduce(into state: inout State, action: Action) async -> Effect<Action> {
        print("daslkdjaksjd")
        switch action {
        case let .textProvided(text):
            print("daskdjaskjdkas")
            guard state.searchPhrase != text else {
                return .none
            }
            state.searchPhrase = text
            /// TypingCompletionId acts as unique id (hash value). It could be plain string also.
            /// However it adds extra protection, as it's almost impossible to duplicate it.
            struct TypingCompletionId: Hashable {}

            return .send(.searchForRepositories)
            // Debounce typing for 1 second.
                .debounce(id: TypingCompletionId(), for: 1, scheduler: mainQueue)
        case .searchForRepositories:
            state.isAlertPresented = false
            let phrase = state.searchPhrase
            guard !phrase.isEmpty else {
                return .none
            }
            state.isLoading = true
            return await .send(.repositoriesResponse(Result { try await repositoriesClient.searchForRepositories(phrase) }))
        case let .repositoryTapped(url):
            state.urlToShow = url
            return .none
        case let .repositoriesResponse(.success(repositories)):
            state.isLoading = false
            state.repositories = IdentifiedArray(uniqueElements: repositories)
            return .none
        case .repositoriesResponse(.failure):
            state.isLoading = false
            state.isAlertPresented = true
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
    
    @Perception.Bindable var store: StoreOf<RepositoriesReducer>
    @FocusState var isTextFieldFocused: Bool
    
    var body: some View {
        VStack {
            TextField(
                "Search phrase",
                text: $store.searchPhrase.sending(\.textProvided)
            )
            .focused($isTextFieldFocused)
            .padding(.horizontal)
            .padding(.top)
            if store.isLoading {
                ActivityIndicator()
            }
            List {
                ForEach(store.repositories) { repository in
                    RepositoryView(repository: repository)
                        .onTapGesture { store.send(.repositoryTapped(repository.url)) }
                }
            }
        }
        .onAppear { self.isTextFieldFocused = true }
        .alert(
            isPresented: Binding(
                get: { store.isAlertPresented },
                set: { _ in store.send(.alertDismissed) }
            )
        ) {
            Alert(
                title: Text("Sorry, something went wrong."),
                primaryButton: .default(Text("Try again")) {
                    store.send(.searchForRepositories)
                },
                secondaryButton: .cancel { store.send(.alertDismissed) }
            )
        }
        .sheet(isPresented:
                Binding(
                    get: { store.urlToShow != nil },
                    set: { _ in store.send(.webViewDismissed) }
                )
        ) { WebView(url: store.urlToShow!) }
    }
    
}

//struct RepositoriesView_Previews: PreviewProvider {
//
//    static var previews: some View {
//        RepositoriesView(
//            store: .init(initialState: .init(), reducer: RepositoriesReducer())
//        )
//    }
//
//}
