//
//  Dog.swift
//  APISwiftUI
//
//  Created by Jordan Fraughton on 6/4/24.
//

import Foundation
import SwiftUI

struct Dog: Hashable {
    let dogImage: Image
    let dogName: String
    let id = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(dogName)
        hasher.combine(id)
    }
}
