//
//  ContentView.swift
//  RadialView
//
//  Created by 박찬휘 on 8/27/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            Home()
                .navigationTitle("Radial Layout")
        }
    }
}

#Preview {
    ContentView()
}
