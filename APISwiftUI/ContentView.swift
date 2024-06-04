//
//  ContentView.swift
//  APISwiftUI
//
//  Created by Jordan Fraughton on 6/4/24.
//

import SwiftUI

struct ContentView: View {
    typealias Dependencies = DogImageResolving & RepResolving
    @StateObject var dogViewModel: DogView.ViewModel
    @StateObject var repViewModel: RepView.ViewModel
    // nobelViewModel
    
    init(resolver: Dependencies) {
        _dogViewModel = .init(wrappedValue: .init(dogFetcher: resolver.resolveDogImageFetching()))
        _repViewModel = .init(wrappedValue: .init(repFetcher: resolver.resolveRepFetching()))
    }
    
    var body: some View {
        TabView {
            DogView(viewModel: dogViewModel)
                .tabItem {
                    Label("Dogs", systemImage: "dog")
                }
            RepView(viewModel: repViewModel)
                .tabItem {
                    Label("Reps", systemImage: "star")
                }
        }
    }
}
