//
//  DogView.swift
//  APISwiftUI
//
//  Created by Jordan Fraughton on 6/4/24.
//

import SwiftUI

struct DogDetailView: View {
    var dog: Dog
    
    var body: some View {
        VStack {
            dog.dogImage
            Text(dog.dogName)
        }
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
                            NavigationLink(value: dog) {
                                DogRowView(dog: dog)
                            }
                            .navigationDestination(for: Dog.self) { dog in
                                DogDetailView(dog: dog)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Dogs")
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
