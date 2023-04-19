//
//  MainMenu.swift
//
//
//  Created by Christopher Gunadi on 17/04/23.
//
//
//  Additional Notes Below!

import SpriteKit
import SwiftUI

class MainMenu: SKScene {
    
    // MARK: - Properties & Variables
    
    private let transition = SKTransition.fade(withDuration: 0.5)
    let label = SKLabelNode(fontNamed:"bitfont")
    private var roadAnimation: RoadAnimation?
    
    // MARK: - Content
    
    override func didMove(to view: SKView) {
        self.backgroundColor = UIColor.clear
        
        // Call Road Animation
        roadAnimation = RoadAnimation(scene: self)
        
        // Play Button
        let playButton = SKSpriteNode(imageNamed: "playbutton.png")
        playButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        playButton.zPosition = 1
        playButton.name = "playButton" // Set the name of the play button node
        self.addChild(playButton)
        
        // Title : Project
        let titleLabel = SKLabelNode(text: "Project")
        titleLabel.position = CGPoint(x: self.frame.midX, y: self.frame.maxY - 100)
        titleLabel.fontSize = 60
        titleLabel.fontName = "Chalkduster"
        titleLabel.fontColor = SKColor.white
        titleLabel.zPosition = 1
        self.addChild(titleLabel)
        
        // Title : Roadside
        let roadsideLabel = SKLabelNode(text: "Roadside")
        roadsideLabel.position = CGPoint(x: self.frame.midX, y: titleLabel.position.y - titleLabel.frame.size.height - 10)
        roadsideLabel.fontSize = 60
        roadsideLabel.fontName = "Chalkduster"
        roadsideLabel.fontColor = SKColor.white
        roadsideLabel.zPosition = 1
        self.addChild(roadsideLabel)
    }
    
    
    // MARK: - Touch Behavior
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let nodesAtLocation = nodes(at: location)
            
            //Touch Transition
            for node in nodesAtLocation {
                if node.name == "playButton" {
                    let gameScene = GameScene(size: self.size)
                    gameScene.scaleMode = .aspectFill
                    view?.presentScene(gameScene)
                }
            }
        }
    }
}

