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

struct Rep: Codable, Hashable {
    var name: String
    var party: String
    var link: URL
}

struct RepSearchResponse: Codable {
    let results: [Rep]
}

struct Laureate: Codable, Hashable {
    var firstname: String
    var surname: String
}

struct Category: Codable, Hashable {
    var year: String
    var category: String
    var laureates: [Laureate]
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        lhs.category == rhs.category
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(year)
        hasher.combine(category)
    }
}

struct Prizes: Codable {
    var prizes: [Category]
}

protocol DogImageFetching {
    func fetchDogPhoto(from url: URL) async throws -> Image
    func fetchDogInfo() async throws -> DogImageURL
    func getDogImage() async throws -> Image 
}

protocol RepFetching {
    func fetchReps(matching query: [String: String]) async throws -> [Rep]
}

protocol PrizeFetching {
    func fetchPrizes(matching query: [String: String]) async throws -> Prizes
}

protocol DogImageResolving {
    func resolveDogImageFetching() -> DogImageFetching
}

protocol RepResolving {
    func resolveRepFetching() -> RepFetching
}

protocol PrizeResolving {
    func resolvePrizeFetching() -> PrizeFetching
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

class RepFetcher: RepFetching {
    enum RepControllerError: Error, LocalizedError {
        case repNotFound
    }
    
    func fetchReps(matching query: [String: String]) async throws -> [Rep] {
        var urlComponents = URLComponents(string: "https://whoismyrepresentative.com/getall_mems.php")!
        urlComponents.queryItems = query.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        
        urlComponents.queryItems?.append(URLQueryItem(name: "output", value: "json"))
        
        let (data, response) = try await URLSession.shared.data(from: urlComponents.url!)
    
        guard
            let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200 else {
            throw RepControllerError.repNotFound
        }
        
        let jsonDecoder = JSONDecoder()
        let searchResponse = try jsonDecoder.decode(RepSearchResponse.self, from: data)
        return searchResponse.results
    }
}

class PrizeFetcher: PrizeFetching {
    enum PrizeError: Error, LocalizedError {
        case PrizesNotFound
    }
    
    func fetchPrizes(matching query: [String : String]) async throws -> Prizes {
        var urlComponents = URLComponents(string: "https://api.nobelprize.org/v1/prize.json")!
        urlComponents.queryItems = query.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        
        let (data, response) = try await URLSession.shared.data(from: urlComponents.url!)
        
        guard
            let httpResonse = response as? HTTPURLResponse,
            httpResonse.statusCode == 200 else {
            throw PrizeError.PrizesNotFound
        }
        
        let jsonDecoder = JSONDecoder()
        let searchResponse = try jsonDecoder.decode(Prizes.self, from: data)
        
        return searchResponse
    }
}

class ExternalDependencyResolver: DogImageResolving, RepResolving, PrizeResolving {
    func resolveRepFetching() -> any RepFetching {
        RepFetcher()
    }
    
    func resolveDogImageFetching() -> any DogImageFetching {
        DogImageFetcher()
    }
    
    func resolvePrizeFetching() -> any PrizeFetching {
        PrizeFetcher()
    }
}
