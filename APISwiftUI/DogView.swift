//
//  DogView.swift
//  APISwiftUI
//
//  Created by Jordan Fraughton on 6/4/24.
//

import SwiftUI

struct DogDetailView: View {
    @Binding var dog: Dog
    
    var body: some View {
        VStack {
            dog.dogImage
            TextField(dog.dogName, text: $dog.dogName)
        }
        .padding()
    }
}

struct DogRowView: View {
    var dog: Dog
    
    var body: some View {
        HStack {
            dog.dogImage
                .resizable()
                .scaledToFit()
                .frame(width: 45, height: 45)
            Text(dog.dogName)
        }
    }
}

struct DogView: View {
    @StateObject var viewModel: ViewModel
    
    init(viewModel: DogView.ViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                VStack {
                    if let image = viewModel.currentDogImage {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                    } else {
                        ProgressView()
                            .frame(height: 200)
                    }
                    TextField("Name?", text: $viewModel.dogName)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    Button {
                        viewModel.loadNewImage()
                    } label: {
                        Text("Save and Generate new")
                    }
                }
                .padding()
                .onAppear {
                    viewModel.onAppear()
                }
                
                if !viewModel.dogs.isEmpty {
                    List {
                        ForEach(viewModel.dogs, id: \.self) { dog in
                            NavigationLink(value: dog.id) {
                                DogRowView(dog: dog)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Dogs")
            .navigationDestination(for: UUID.self) { id in
                DogDetailView(dog: $viewModel[id])
            }
        }
    }
}

extension DogView {
    @MainActor
    class ViewModel: ObservableObject {
        private let dogFetcher: DogImageFetching
        
        @Published var dogs: [Dog] = []
        @Published var currentDogImage: Image?
        @Published var dogName: String = ""
        
        init(dogFetcher: DogImageFetching) {
            self.dogFetcher = dogFetcher
        }
        
        subscript(id: UUID) -> Dog {
            get {
                dogs.first { $0.id == id } ?? Dog(dogImage: Image(systemName: "exclamationmark.triangle"), dogName: "No dog")
            } 
            set {
                dogs = dogs.map { $0.id == id ? newValue : $0 }
            }
        }
        
        func loadNewImage() {
            saveDog()
            Task {
                currentDogImage = try await dogFetcher.getDogImage()
            }
        }
        
        func saveDog() {
            if let currentDogImage {
                let dog = Dog(dogImage: currentDogImage, dogName: dogName)
                dogs.append(dog)
                dogName = ""
            }
            currentDogImage = nil
        }
        
        func onAppear() {
            Task {
                currentDogImage = try await dogFetcher.getDogImage()
            }
        }
    }
}
