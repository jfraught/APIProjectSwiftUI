//
//  ContentView.swift
//  APISwiftUI
//
//  Created by Jordan Fraughton on 6/4/24.
//

import SwiftUI

struct ContentView: View {
    typealias Dependencies = DogImageResolving & RepResolving & PrizeResolving
    @StateObject var dogViewModel: DogView.ViewModel
    @StateObject var repViewModel: RepView.ViewModel
    @StateObject var nobelViewModel: NobelView.ViewModel
    
    init(resolver: Dependencies) {
        _dogViewModel = .init(wrappedValue: .init(dogFetcher: resolver.resolveDogImageFetching()))
        _repViewModel = .init(wrappedValue: .init(repFetcher: resolver.resolveRepFetching()))
        _nobelViewModel = .init(wrappedValue: .init(prizeFetcher: resolver.resolvePrizeFetching()))
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
            NobelView(viewModel: nobelViewModel)
                .tabItem {
                    Label("Nobel", systemImage: "brain.filled.head.profile")
                }
        }
    }
}
