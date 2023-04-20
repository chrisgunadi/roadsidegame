//
//  SpriteKitView.swift
//
//
//  Created by Christopher Gunadi on 18/04/23.
//

import SwiftUI
import SpriteKit

struct SpriteKitView: UIViewRepresentable {
    let scene: SKScene

    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.ignoresSiblingOrder = true
        return view
    }

    func updateUIView(_ uiView: SKView, context: Context) {
        uiView.presentScene(scene)
    }
}
