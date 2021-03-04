//
//  ActivityIndicator.swift
//  GitHubSearch
//
//  Created by Bartosz Kucharski on 04/03/2021.
//

import SwiftUI

struct ActivityIndicator: UIViewRepresentable {
    
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView()
        view.startAnimating()
        return view
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) { }
}
