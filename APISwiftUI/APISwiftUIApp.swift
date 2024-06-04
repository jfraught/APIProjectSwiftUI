//
//  APISwiftUIApp.swift
//  APISwiftUI
//
//  Created by Jordan Fraughton on 6/4/24.
//

import SwiftUI

@main
struct APISwiftUIApp: App {
    let externalResolver = ExternalDependencyResolver()
    var body: some Scene {
        WindowGroup {
            ContentView(resolver: externalResolver)
        }
    }
}
