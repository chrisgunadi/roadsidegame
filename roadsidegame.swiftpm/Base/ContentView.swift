//
//  ContentView.swift
//
//
//  Created by Christopher Gunadi on 16/04/23.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    var body: some View {
        SpriteKitView(scene: MainMenu(size: UIScreen.main.bounds.size))
            .edgesIgnoringSafeArea(.all)
    }
}


