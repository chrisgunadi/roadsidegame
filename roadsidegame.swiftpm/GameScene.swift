//
//  GameScene.swift
//
//
//  Created by Christopher Gunadi on 17/04/23.
//

import SpriteKit
import GameplayKit

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
    
    //Difficulty
    var currentLevel: Int = 6
    let levelUpInterval: TimeInterval = 8
    
    //Game Data
    var score: Int = 0
    
    //Game Over
    var isGameOver: Bool = false
    var isGameOverPopupOn: Bool = false
    var timeRestartDelay: CFTimeInterval = 1.0
    var timeOfGameOver: CFTimeInterval = 0.0
    
    
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
        print(laneWidth)
        lanePosition = [-laneWidth, 0, laneWidth]
        stripPosition = [lanePosition [0] * 0.5 , lanePosition [2] * 0.5]
        touchController = TouchController(center: view.frame.size.width / 2)
        
        self.backgroundColor = UIColor.lightGray
        self.anchorPoint = CGPoint(x:0.5, y:0.5)
        
        addPlayerCar()
        
        let levelUpAction = SKAction.run {
            self.currentLevel = min(self.currentLevel - 1, 2)
            print("Level: \(self.currentLevel)")
        }
        
        let waitActionLevel = SKAction.wait(forDuration: levelUpInterval)
        let levelUpSequence = SKAction.sequence([levelUpAction, waitActionLevel])
        let levelUpRepeat = SKAction.repeat(levelUpSequence, count: 1) // Run 1 time to reach level 6
        self.run(levelUpRepeat)
        
        randomCarSpawning()
        
        let createRoadStripAction = SKAction.run(createRoadStrip)
        let waitAction = SKAction.wait(forDuration: 0.3)
        let sequence = SKAction.sequence([createRoadStripAction, waitAction])
        let repeatForever = SKAction.repeatForever(sequence)
        self.run(repeatForever)
        
        // Set up physics bodies for player car and traffic car
        
        
        
        
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
    
    func addTrafficCar(inLane laneIndex: Int, speedMultiplier: Int) {
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
        
        let moveDownSpeed = CGFloat(200 + (50 * (speedMultiplier - 1))) // Increase speed based on level
        let moveDown = SKAction.moveBy(x: 0, y: -self.frame.height * 1.25, duration: TimeInterval(6 - (speedMultiplier - 1)))
        let removeAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([moveDown, removeAction])
        trafficCar.run(sequence)
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
        let randomLane = Int.random(in: 0..<lanePosition.count)
        addTrafficCar(inLane: randomLane, speedMultiplier: currentLevel)
        
        let spawnDuration = max(1 - TimeInterval(6 - currentLevel) * 0.333, 1)
        
        // Spawn a car in a second lane with a 15% chance
        if Int.random(in: 1...100) <= 15 {
            var secondRandomLane = Int.random(in: 0..<lanePosition.count)
            while secondRandomLane == randomLane {
                secondRandomLane = Int.random(in: 0..<lanePosition.count)
            }
            addTrafficCar(inLane: secondRandomLane, speedMultiplier: currentLevel)
        }
        
        let carWaitAction = SKAction.wait(forDuration: spawnDuration)
        let carSequence = SKAction.sequence([carWaitAction, SKAction.run(randomCarSpawning)])
        self.run(carSequence)
    }
    
    override func update(_ currentTime: TimeInterval) {
        for roadStrip in roadStrips {
            let moveDownSpeed = CGFloat(200 + (50 * (currentLevel + 1))) // Increase speed based on level
            let moveDown = SKAction.moveBy(x: 0, y: -200, duration: TimeInterval(6 - (currentLevel - 1)))
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
    
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if collision == CollisionType.playerCar.rawValue | CollisionType.trafficCar.rawValue {
            // Stop all actions and physics simulation in the current scene
            self.removeAllActions()
            self.physicsWorld.speed = 0
            
            
        }
    }
    // MARK: - Physics
    
}

    

