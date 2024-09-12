//
//  GitHubSearchApp.swift
//  GitHubSearch
//
//  Created by Bartosz Kucharski on 03/03/2021.
//

import SwiftUI
import ComposableArchitecture
import Combine

@main
struct GitHubSearchApp: App {
  
  var body: some Scene {
      WindowGroup { AppView(store: .init(initialState: .init(), reducer: { AppReducer() })) }
  }
  
}
