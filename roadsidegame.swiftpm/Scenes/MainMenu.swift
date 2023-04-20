//
//  MainMenu.swift
//
//
//  Created by Christopher Gunadi on 17/04/23.
//
//

import SpriteKit
import SwiftUI
import AVFoundation



class MainMenu: SKScene {
    
    // MARK: - Properties & Variables
    
    private let transition = SKTransition.fade(withDuration: 0.5)
    let label = SKLabelNode(fontNamed:"bitfont")
    private var roadAnimation: RoadAnimation?
    var backgroundMusicPlayer: AVAudioPlayer?

    
    // MARK: - Content
    
    override func didMove(to view: SKView) {
        self.backgroundColor = UIColor.clear
        
        // Call Road Animation
        roadAnimation = RoadAnimation(scene: self)
        
        func textureFromSFSymbol(name: String, pointSize: CGFloat) -> SKTexture? {
            if let image = UIImage(systemName: name) {
                let configuration = UIImage.SymbolConfiguration(pointSize: pointSize)
                let scaledImage = image.withConfiguration(configuration)
                return SKTexture(image: scaledImage)
            }
            return nil
        }
        
        func playBackgroundMusic() {
            if let backgroundMusicURL = Bundle.main.url(forResource: "bgmusicplay", withExtension: "mp3") {
                do {
                    backgroundMusicPlayer = try AVAudioPlayer(contentsOf: backgroundMusicURL)
                    backgroundMusicPlayer?.numberOfLoops = -1
                    backgroundMusicPlayer?.volume = 0.2
                    backgroundMusicPlayer?.prepareToPlay()
                    backgroundMusicPlayer?.play()
                    
                } catch {
                    print("Error playing background music: \(error.localizedDescription)")
                }
            }
        }

        playBackgroundMusic()

        
        // Play Button (Let's change to SF Symbols instead of using a png!)
        //        let playButton = SKSpriteNode(imageNamed: "playbutton.png")
        //        playButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        //        playButton.zPosition = 1
        //        playButton.name = "playButton"
        //        self.addChild(playButton)
        
        if let playButtonTexture = textureFromSFSymbol(name: "play.fill", pointSize: 150) {
            let playButton = SKSpriteNode(texture: playButtonTexture)
            playButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            playButton.zPosition = 1
            playButton.name = "playButton"
            self.addChild(playButton)
            
            // Idle animation: bobbing up and down
            let moveUp = SKAction.moveBy(x: 0, y: 10, duration: 0.5)
            let moveDown = SKAction.moveBy(x: 0, y: -10, duration: 0.5)
            let bobbingAnimation = SKAction.sequence([moveUp, moveDown])
            let repeatBobbing = SKAction.repeatForever(bobbingAnimation)
            playButton.run(repeatBobbing)
            
            
            
            
            // Title : Project
            let titleLabel = SKLabelNode(text: "Project")
            titleLabel.position = CGPoint(x: self.frame.midX, y: self.frame.maxY - 150)
            titleLabel.fontSize = 70
            titleLabel.fontName = "Chalkduster"
            titleLabel.fontColor = SKColor.white
            titleLabel.zPosition = 1
            titleLabel.run(repeatBobbing)
            self.addChild(titleLabel)
            
            // Title : Roadside
            let roadsideLabel = SKLabelNode(text: "Roadside")
            roadsideLabel.position = CGPoint(x: self.frame.midX, y: titleLabel.position.y - titleLabel.frame.size.height - 20)
            roadsideLabel.fontSize = 70
            roadsideLabel.fontName = "Chalkduster"
            roadsideLabel.fontColor = SKColor.white
            roadsideLabel.zPosition = 1
            roadsideLabel.run(repeatBobbing)
            self.addChild(roadsideLabel)
            
            // Story & Credits Button
            let storyButton = SKLabelNode(text: "The Story")
            storyButton.position = CGPoint(x: frame.midX, y: frame.midY - 350)
            storyButton.fontSize = 40
            storyButton.fontName = "Chalkduster"
            storyButton.fontColor = SKColor.white
            storyButton.zPosition = 1
            storyButton.name = "storyButton"


            self.addChild(storyButton)
        }
    }
    
    
    // MARK: - Touch Behavior
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let nodesAtLocation = nodes(at: location)
            
            // Touch Down Behavior
            for node in nodesAtLocation {
                if node.name == "playButton" {
                    let scaleDown = SKAction.scale(by: 0.9, duration: 0.5)
                    node.run(scaleDown)
                } else if node.name == "storyButton" {
                    let spriteNode = node as! SKLabelNode
                    spriteNode.fontColor = .green
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let nodesAtLocation = nodes(at: location)
            
            // Touch Up
            for node in nodesAtLocation {
                if node.name == "playButton" {
                    let scaleUp = SKAction.scale(by: 1/0.9, duration: 0.5)
                    node.run(scaleUp)
                    
                    // Transition to the GameScene
                    backgroundMusicPlayer?.stop()
                    let gameScene = GameScene(size: self.size)
                    gameScene.scaleMode = .aspectFill
                    view?.presentScene(gameScene, transition: transition)
                } else if node.name == "storyButton" {
                    backgroundMusicPlayer?.stop()
                        let storyScene = StoryScene(size: self.size)
                        storyScene.scaleMode = .aspectFill
                        view?.presentScene(storyScene, transition: transition)
                    }
                }
            }
        }
    }
