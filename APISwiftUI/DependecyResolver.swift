//
//  DependencyResolver.swift
//  APISwiftUI
//
//  Created by Jordan Fraughton on 6/4/24.
//

import Foundation
import SwiftUI

struct DogImageURL: Codable {
    var imageURL: URL
    
    enum CodingKeys: String, CodingKey {
        case imageURL = "message"
    }
}

protocol DogImageFetching {
    func fetchDogPhoto(from url: URL) async throws -> Image
    func fetchDogInfo() async throws -> DogImageURL
    func getDogImage() async throws -> Image 
}

protocol DogImageResolving {
    func resolveDogImageFetching() -> DogImageFetching
}

class DogImageFetcher: DogImageFetching {
    enum DogError: Error, LocalizedError {
        case dogNotFound
        case imageDataMissing
    }
    
    func fetchDogPhoto(from url: URL) async throws -> Image {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard
            let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200 else {
            throw DogError.imageDataMissing
        }
        
        guard let uiImage = UIImage(data: data) else {
            throw DogError.imageDataMissing
        }
        
        let image = Image(uiImage: uiImage)
        
        return image
    }
    
    func fetchDogInfo() async throws -> DogImageURL {
        let url = URL(string: "https://dog.ceo/api/breeds/image/random")!
       
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard
            let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200 else {
            throw DogError.dogNotFound
        }
        
        let jsonDecoder = JSONDecoder()
        let dogImageURL = try jsonDecoder.decode(DogImageURL.self, from: data)
        
        return dogImageURL
    }
    
    func getDogImage() async throws -> Image {
        do {
            let dogImageURL = try await fetchDogInfo()
            let image = try await fetchDogPhoto(from: dogImageURL.imageURL)
            return image
        } catch {
            print(error)
            throw error
        }
    }
}

class ExternalDependencyResolver: DogImageResolving {
    func resolveDogImageFetching() -> any DogImageFetching {
        DogImageFetcher()
    }
}
