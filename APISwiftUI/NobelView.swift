//
//  NobelView.swift
//  APISwiftUI
//
//  Created by Jordan Fraughton on 6/4/24.
//

import SwiftUI

struct NobelView: View {
    @StateObject var viewModel: ViewModel
    
    init(viewModel: NobelView.ViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List {
                if let prizes = viewModel.prizes {
                    ForEach(prizes.prizes, id: \.self) { category in
                        Section(header: Text(category.category.capitalized)) {
                            ForEach(category.laureates, id: \.self) { laureate in
                                Text("\(laureate.firstname.capitalized) \(laureate.surname.capitalized)")
                            }
                            
                        }
                    }
                }
            }
            .searchable(text: $searchText)
            .onChange(of: searchText, { oldValue, newValue in
                viewModel.loadPrizes(from: newValue)
            })
            .navigationTitle("Nobel Prize Laureates")
        }
    }
}

extension NobelView {
    @MainActor
    class ViewModel: ObservableObject {
        private let prizeFetcher: PrizeFetching
        
        @Published var prizes: Prizes? 
        
        init(prizeFetcher: PrizeFetching) {
            self.prizeFetcher = prizeFetcher
        }
        
        func loadPrizes(from year: String) {
            if !year.isEmpty {
                let queryItems = ["year": year]
                
                Task {
                    do {
                        prizes = try await prizeFetcher.fetchPrizes(matching: queryItems)
                    } catch {
                        prizes = nil
                        print(error)
                    }
                }
            }
        }
    }
}
