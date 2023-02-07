//
//  WebView.swift
//  GitHubSearch
//
//  Created by Bartosz Kucharski on 04/03/2021.
//

import WebKit
import SwiftUI

struct WebView: UIViewRepresentable {

  private let url: URL

  init(url: URL) {
    self.url = url
  }

  func makeUIView(context: Context) -> WKWebView {
    let webView = WKWebView()
    webView.load(.init(url: url))
    return webView
  }

  func updateUIView(_ uiView: WKWebView, context: Context) {}

}
