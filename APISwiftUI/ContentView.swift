//
//  ContentView.swift
//  APISwiftUI
//
//  Created by Jordan Fraughton on 6/4/24.
//

import SwiftUI

struct ContentView: View {
    typealias Dependencies = DogImageResolving
    @StateObject var dogViewModel: DogView.ViewModel
    
    init(resolver: Dependencies) {
        _dogViewModel = .init(wrappedValue: .init(dogFetcher: resolver.resolveDogImageFetching()))
    }
    
    var body: some View {
        TabView {
            DogView(viewModel: dogViewModel)
                .tabItem {
                    Label("Dogs", systemImage: "dog")
                }
        }
    }
}
