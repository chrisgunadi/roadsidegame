//
//  GameScene.swift
//
//
//  Created by Christopher Gunadi on 17/04/23.
//

import SpriteKit
import GameplayKit
import SwiftUI
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Properties & Variables
    
    //Entities
    var playerCar = SKSpriteNode()
    var trafficCar = SKSpriteNode()
    
    //Road and Lanes
    var roadStrips: [SKShapeNode] = []
    var lanePosition: [CGFloat] = []
    var stripPosition: [CGFloat] = []
    
    //Touch Response!
    var touchController: TouchController!
    
    //Difficulty (Ommited because I want to send a different kind of message)
    //    var currentLevel: Int = 6
    //    let levelUpInterval: TimeInterval = 8
    
    //Game Scoring
    var score: Int = 0
    var scoreLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
    
    
    //Game Over
    var isGameOver: Bool = false
    var isGameOverPopupOn: Bool = false
    var timeRestartDelay: CFTimeInterval = 1.0
    var timeOfGameOver: CFTimeInterval = 0.0
    
    var pointSoundPlayer: AVAudioPlayer?
    var crashSoundPlayer: AVAudioPlayer?
    var sirenPlayer: AVAudioPlayer?
    
    var countdownCompleted: Bool = false
    
    private var mainMenuLabel: SKLabelNode!

    
    enum CollisionType: UInt32 {
        case playerCar = 1
        case trafficCar = 2
    }
    
    
    class TouchController {
        let center: CGFloat
        
        init(center: CGFloat) {
            self.center = center
        }
        
        func moveDirection(from touch: UITouch) -> CGFloat {
            return touch.location(in: touch.view).x < center ? -1 : 1
        }
    }
    
    // MARK: - UI Screen Border Definition
    
    override func didMove(to view: SKView) {
        let screenWidth = view.frame.width
        let laneWidth = screenWidth / 3
        lanePosition = [-laneWidth, 0, laneWidth]
        stripPosition = [lanePosition [0] * 0.5 , lanePosition [2] * 0.5]
        touchController = TouchController(center: view.frame.size.width / 2)
        startCountdown()
        
        self.backgroundColor = UIColor.lightGray
        self.anchorPoint = CGPoint(x:0.5, y:0.5)
        
        self.physicsWorld.contactDelegate = self
        
        
        addPlayerCar()
        
        //        let levelUpAction = SKAction.run {
        //            self.currentLevel = min(self.currentLevel - 1, 2)
        //            print("Level: \(self.currentLevel)")
        //        }
        //
        //        let waitActionLevel = SKAction.wait(forDuration: levelUpInterval)
        //        let levelUpSequence = SKAction.sequence([levelUpAction, waitActionLevel])
        //        let levelUpRepeat = SKAction.repeat(levelUpSequence, count: 1) // Run 1 time to reach level 6
        //        self.run(levelUpRepeat)
        
        randomCarSpawning()
        
        let createRoadStripAction = SKAction.run(createRoadStrip)
        let waitAction = SKAction.wait(forDuration: 0.3)
        let sequence = SKAction.sequence([createRoadStripAction, waitAction])
        let repeatForever = SKAction.repeatForever(sequence)
        self.run(repeatForever)
        
        scoreLabel.fontSize = 30
        scoreLabel.fontColor = UIColor.white
        scoreLabel.position = CGPoint(x: -self.frame.width/2 + 80, y: self.frame.height/2 - 50)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.text = "Score: \(score)"
        scoreLabel.zPosition = 2
        addChild(scoreLabel)
        
        // Load point sound
        if let pointSoundURL = Bundle.main.url(forResource: "point", withExtension: "mp3") {
            do {
                pointSoundPlayer = try AVAudioPlayer(contentsOf: pointSoundURL)
                pointSoundPlayer?.prepareToPlay()
                pointSoundPlayer?.volume = 0.8
            } catch {
                print("Error loading point sound: \(error)")
            }
        }
        
        // Load crash sound
        if let crashSoundURL = Bundle.main.url(forResource: "crash", withExtension: "mp3") {
            do {
                crashSoundPlayer = try AVAudioPlayer(contentsOf: crashSoundURL)
                crashSoundPlayer?.prepareToPlay()
                crashSoundPlayer?.volume = 0.8
            } catch {
                print("Error loading crash sound: \(error)")
            }
        }
        
        if let sirenURL = Bundle.main.url(forResource: "siren", withExtension: "mp3") {
            do {
                sirenPlayer = try AVAudioPlayer(contentsOf: sirenURL)
                sirenPlayer?.numberOfLoops = -1 // loop indefinitely
                sirenPlayer?.volume = 0.8 // set volume to 80%
            } catch {
                print("Error loading siren sound: \(error)")
            }
        }
        sirenPlayer?.play()
        
        
        
        
        
        
    }
    
    // MARK: - Spawn Player and Traffic
    
    
    
    func addPlayerCar() {
        playerCar = SKSpriteNode(imageNamed: "ambulance")
        playerCar.position = CGPoint(x: lanePosition[1], y: -self.frame.height/2 + playerCar.size.height/4 + 50)
        playerCar.setScale(0.5)
        playerCar.zPosition = 1
        addChild(playerCar)
        playerCar.physicsBody = SKPhysicsBody(rectangleOf: playerCar.size)
        playerCar.physicsBody!.categoryBitMask = CollisionType.playerCar.rawValue
        playerCar.physicsBody!.collisionBitMask = CollisionType.trafficCar.rawValue
        playerCar.physicsBody!.contactTestBitMask = CollisionType.trafficCar.rawValue
        playerCar.physicsBody!.affectedByGravity = false
        playerCar.physicsBody!.isDynamic = true
        
        
        
        
    }
    
    func addTrafficCar(inLane laneIndex: Int) {
        let carTextures = [
            SKTexture(imageNamed: "car1"),
            SKTexture(imageNamed: "car2"),
            SKTexture(imageNamed: "car3"),
            SKTexture(imageNamed: "car4"),
            SKTexture(imageNamed: "car5")
        ]
        trafficCar = SKSpriteNode(texture: carTextures.randomElement())
        trafficCar.setScale(0.5)
        trafficCar.zPosition = 1
        trafficCar.position.x = lanePosition[laneIndex]
        trafficCar.position.y = 750
        trafficCar.physicsBody = SKPhysicsBody(rectangleOf: trafficCar.size)
        trafficCar.physicsBody!.categoryBitMask = CollisionType.trafficCar.rawValue
        trafficCar.physicsBody!.collisionBitMask = CollisionType.playerCar.rawValue
        trafficCar.physicsBody!.contactTestBitMask = CollisionType.playerCar.rawValue
        trafficCar.physicsBody!.affectedByGravity = false
        trafficCar.physicsBody!.isDynamic = true
        addChild(trafficCar)
        
        let moveDown = SKAction.moveBy(x: 0, y: -self.frame.height * 1.25, duration: TimeInterval(2)) // Fixed speed
        let removeAction = SKAction.removeFromParent()
        let incrementScoreAction = SKAction.run {
            self.score += 1
            self.scoreLabel.text = "Score: \(self.score)"
            self.pointSoundPlayer?.play()
        }
        let sequence = SKAction.sequence([moveDown, incrementScoreAction, removeAction])
        trafficCar.run(sequence)
        
    }
    
    // MARK: - Countdown
    
    func startCountdown() {
        let countdownLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        countdownLabel.fontSize = 50
        countdownLabel.fontColor = UIColor.white
        countdownLabel.position = CGPoint(x: 0, y: 0)
        countdownLabel.zPosition = 2
        addChild(countdownLabel)
        
        let countdownSequence = SKAction.sequence([
            SKAction.run { countdownLabel.text = "Tap left to move left" },
            SKAction.wait(forDuration: 1),
            SKAction.run { countdownLabel.text = "Tap right to move right" },
            SKAction.wait(forDuration: 1),
            SKAction.run { countdownLabel.text = "2" },
            SKAction.wait(forDuration: 1),
            SKAction.run { countdownLabel.text = "1" },
            SKAction.wait(forDuration: 1),
            SKAction.run { countdownLabel.text = "GO!" },
            SKAction.wait(forDuration: 1),
            SKAction.run {
                countdownLabel.removeFromParent()
                self.countdownCompleted = true // set the flag here
                self.randomCarSpawning() // start car spawning after countdown is complete
            }
        ])
        
        countdownLabel.run(countdownSequence)
    }


    
    
    // MARK: - Spawn Level Motion
    
    func createRoadStrip(){
        let firstLaneStrip = SKShapeNode(rectOf: CGSize(width: 15, height: 125))
        firstLaneStrip.strokeColor = SKColor.white
        firstLaneStrip.fillColor = SKColor.white
        firstLaneStrip.alpha = 0.8
        firstLaneStrip.name = "firstLaneStrip"
        firstLaneStrip.zPosition = 0
        firstLaneStrip.position.x = stripPosition[0]
        firstLaneStrip.position.y = self.frame.height * 0.75 + firstLaneStrip.frame.height/2
        addChild(firstLaneStrip)
        
        let secondLaneStrip = firstLaneStrip.copy() as! SKShapeNode
        secondLaneStrip.position.x = stripPosition[1]
        addChild(secondLaneStrip)
        
        roadStrips.append(firstLaneStrip)
        roadStrips.append(secondLaneStrip)
        
    }
    
    func randomCarSpawning() {
        if !countdownCompleted {
            return
        }
        let randomLane = Int.random(in: 0..<lanePosition.count)
        addTrafficCar(inLane: randomLane)
        
        let spawnDuration = TimeInterval(1) // Fixed spawn duration
        
        // 15% car chance second lane
        if Int.random(in: 1...100) <= 15 {
            var secondRandomLane = Int.random(in: 0..<lanePosition.count)
            while secondRandomLane == randomLane {
                secondRandomLane = Int.random(in: 0..<lanePosition.count)
            }
            addTrafficCar(inLane: secondRandomLane)
        }
        
        let carWaitAction = SKAction.wait(forDuration: spawnDuration)
        let carSequence = SKAction.sequence([carWaitAction, SKAction.run(randomCarSpawning)])
        self.run(carSequence)
    }
    
    override func update(_ currentTime: TimeInterval) {
        for roadStrip in roadStrips {
            let moveDown = SKAction.moveBy(x: 0, y: -200, duration: TimeInterval(2)) // Fixed speed
            roadStrip.run(moveDown)
            
            if roadStrip.position.y < -self.frame.height/2 - roadStrip.frame.height/2 {
                roadStrip.removeFromParent()
                if let index = roadStrips.firstIndex(of: roadStrip) {
                    roadStrips.remove(at: index)
                }
            }
        }
    }
    
    // MARK: - LANE MOVING FUNCTION. FINALLY WORKS, DO NOT MODIFY FURTHER!
    // Modify lanePosition instead.
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let direction = touchController.moveDirection(from: touch)
        
        if direction == -1 { // Left side of the screen touched
            if let currentIndex = lanePosition.firstIndex(of: playerCar.position.x) {
                if currentIndex > 0 {
                    playerCar.run(SKAction.moveTo(x: lanePosition[currentIndex - 1], duration: 0.15))
                }
            }
        } else { // Right side of the screen touched
            if let currentIndex = lanePosition.firstIndex(of: playerCar.position.x) {
                if currentIndex < lanePosition.count - 1 {
                    playerCar.run(SKAction.moveTo(x: lanePosition[currentIndex + 1], duration: 0.15))
                }
            }
        }
    }
    
    func displayGameOver() {
        let gameOverScene = GameOverScene(size: size, score: score)
        gameOverScene.scaleMode = scaleMode
        
        let reveal = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(gameOverScene, transition: reveal)
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        print("Collision detected")
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if collision == CollisionType.playerCar.rawValue | CollisionType.trafficCar.rawValue {
            sirenPlayer?.stop()
            self.removeAllActions()
            self.physicsWorld.speed = 0
            isGameOver = true
            crashSoundPlayer?.play()
            displayGameOver()
        }
        
        
    }
    
    
    
    
    
    class GameOverScene: SKScene {
        var notificationLabel = SKLabelNode(text: "Game Over")
        var scoreLabel = SKLabelNode(text: "")
        var tapToRestartLabel = SKLabelNode(text: "Tap anywhere to restart")
        
        init(size: CGSize, score: Int) {
            super.init(size: size)
            
            self.backgroundColor = SKColor.darkGray
            
            addChild(notificationLabel)
            notificationLabel.fontSize = 32.0
            notificationLabel.color = SKColor.white
            notificationLabel.fontName = "Thonburi-Bold"
            notificationLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
            
            scoreLabel.fontSize = 28.0
            scoreLabel.color = SKColor.white
            scoreLabel.fontName = "Thonburi-Bold"
            scoreLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 50)
            scoreLabel.text = "Score: \(score)"
            addChild(scoreLabel)
            
            tapToRestartLabel.fontSize = 24.0
            tapToRestartLabel.color = SKColor.white
            tapToRestartLabel.fontName = "Thonburi-Bold"
            tapToRestartLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 100)
            addChild(tapToRestartLabel)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            let gameScene = GameScene(size: size)
            gameScene.scaleMode = scaleMode
            
            let reveal = SKTransition.fade(withDuration: 0.5)
            view?.presentScene(gameScene, transition: reveal)
        }
    }
    
    
    
}
