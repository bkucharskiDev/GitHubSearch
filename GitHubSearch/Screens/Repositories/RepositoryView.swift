//
//  RepositoryView.swift
//  GitHubSearch
//
//  Created by Bartosz Kucharski on 06/03/2021.
//

import SwiftUI
import Kingfisher

struct RepositoryView: View {
    
    private let repository: Repository
    
    init(repository: Repository) {
        self.repository = repository
    }
    
    var body: some View {
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
    }
    
}
