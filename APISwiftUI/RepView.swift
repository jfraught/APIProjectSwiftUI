//
//  RepView.swift
//  APISwiftUI
//
//  Created by Jordan Fraughton on 6/4/24.
//

import SwiftUI

struct RepView: View {
    @StateObject var viewModel: ViewModel
    
    init(viewModel: RepView.ViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.reps, id: \.self) { rep in
                    VStack {
                        Text(rep.name)
                        Text(rep.party)
                    }
                }
            }
            .searchable(text: $searchText)
            .onChange(of: searchText, { oldValue, newValue in
                viewModel.loadReps(from: newValue)
            })
            .navigationTitle("Representatives")
        }
    }
}

extension RepView {
    @MainActor
    class ViewModel: ObservableObject {
        private let repFetcher: RepFetching
        
        @Published var reps: [Rep] = []
        
        init(repFetcher: RepFetching) {
            self.repFetcher = repFetcher
        }
        
        func loadReps(from zipCode: String) {
            if !zipCode.isEmpty {
                let queryItems = ["zip" : zipCode]
                
                Task {
                    do {
                        reps = try await repFetcher.fetchReps(matching: queryItems)
                    } catch {
                        reps = []
                        print(error)
                    }
                }
            }
        }
    }
}
