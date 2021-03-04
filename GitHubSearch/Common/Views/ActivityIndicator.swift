//
//  ActivityIndicator.swift
//  GitHubSearch
//
//  Created by Bartosz Kucharski on 04/03/2021.
//

import SwiftUI

public struct ActivityIndicator: UIViewRepresentable {
    
    public func makeUIView(context: Context) -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView()
        view.startAnimating()
        return view
    }
    
    public func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) { }
}
