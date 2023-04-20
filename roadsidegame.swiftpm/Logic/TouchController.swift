//
//  TouchController.swift
//
//
//  Created by Christopher Gunadi on 18/04/23.
//  Can't believe I had to make a seperate file for Touch functions. It's so frustrating to see touch not working as intended!!

import SpriteKit

class TouchController {
    
    // MARK:
    let lanePositions: [CGFloat]
    let playerCar: SKSpriteNode
    
    init(lanePositions: [CGFloat], playerCar: SKSpriteNode) {
        self.lanePositions = lanePositions
        self.playerCar = playerCar
    }
  
    //MARK: - Function
    
    func handleTouch(_ touchLocation: CGPoint) {
        moveAmbulanceToNearestLane(touchLocation: touchLocation)
    }
    

    private func moveAmbulanceToNearestLane(touchLocation: CGPoint) {
        let currentX = playerCar.position.x
        let touchX = touchLocation.x
        var targetLaneIndex = 0
        
        if touchX < currentX {
            if let index = lanePositions.firstIndex(where: { $0 < currentX }) {
                targetLaneIndex = index - 1
            }
        } else {
            if let index = lanePositions.firstIndex(where: { $0 > currentX }) {
                targetLaneIndex = index
            }
        }
        
        targetLaneIndex = max(0, min(targetLaneIndex, lanePositions.count - 1))
        
        let targetX = lanePositions[targetLaneIndex]
        let moveAction = SKAction.moveTo(x: targetX, duration: 0.3)
        moveAction.timingMode = .easeInEaseOut
        playerCar.run(moveAction)
    }
}
