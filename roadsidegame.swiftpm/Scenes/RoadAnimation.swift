//This is For the Main Menu
//
//  RoadAnimation.swift
//
//
//  Created by Christopher Gunadi on 18/04/23.
//


import SpriteKit

class RoadAnimation {
    
    // MARK: - Properties & Variables
    
    private var backgroundNodes: [SKSpriteNode] = []
    private let numBackgroundNodes = 2
    private let backgroundNodeHeight: CGFloat = 1400
    private var moveupDuration: TimeInterval = 6
    
    // MARK: - Init
    
    init(scene: SKScene) {
        setupBackground(scene: scene)
        startBackgroundAnimation()
    }
    
    // MARK: - Data
    
    private func setupBackground(scene: SKScene) {
        let backgroundTexture = SKTexture(imageNamed: "road1.png")
        for i in 0..<numBackgroundNodes {
            let backgroundNode = SKSpriteNode(texture: backgroundTexture, size: CGSize(width: scene.frame.width, height: backgroundNodeHeight))
            backgroundNode.anchorPoint = CGPoint(x: 0.5, y: 0)
            backgroundNode.position = CGPoint(x: scene.frame.midX, y: scene.frame.minY + (CGFloat(i) * backgroundNodeHeight))
            backgroundNode.zPosition = -1
            scene.addChild(backgroundNode)
            backgroundNodes.append(backgroundNode)
        }
    }
    
    func startBackgroundAnimation() {
        let moveUp = SKAction.moveBy(x: 0, y: -backgroundNodeHeight, duration: moveupDuration)
        let resetPosition = SKAction.moveBy(x: 0, y: backgroundNodeHeight, duration: 0)
        let sequence = SKAction.sequence([moveUp, resetPosition])
        let repeatForever = SKAction.repeatForever(sequence)
        
        for backgroundNode in backgroundNodes {
            backgroundNode.run(repeatForever)
        }
    }
    
    // MARK: - Motion
    
    func speedUp() {
        moveupDuration -= 1
        let moveUp = SKAction.moveBy(x: 0, y: -backgroundNodeHeight, duration: moveupDuration)
        let resetPosition = SKAction.moveBy(x: 0, y: backgroundNodeHeight, duration: 0)
        let sequence = SKAction.sequence([moveUp, resetPosition])
        let repeatForever = SKAction.repeatForever(sequence)
        
        for backgroundNode in backgroundNodes {
            backgroundNode.removeAllActions()
            backgroundNode.run(repeatForever)
        }
    }
    
}
