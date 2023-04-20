//
//  ThirdPageStory.swift
//  
//
//  Created by Christopher Gunadi on 19/04/23.
//

import SpriteKit


class ThirdPageScene: SKScene {
    // MARK: - Content
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .black
        
        let storyText = """
        
        
        Avoid all the cars. Tap on the Left Side of your screen to move left, and tap on the Right Side of your screen to move right.
        
        Sometimes, traffic will be impossible to weave through. I've made it that way to give it a... Jakartan vibe to it.
        
        
        
        Have fun!
        
        ChrisG
        """
        
        let storyLabel = SKLabelNode(text: storyText)
        storyLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        storyLabel.fontSize = 24
        storyLabel.fontName = "Arial"
        storyLabel.fontColor = SKColor.white
        storyLabel.numberOfLines = 0
        storyLabel.preferredMaxLayoutWidth = self.size.width * 0.8
        storyLabel.horizontalAlignmentMode = .center
        storyLabel.verticalAlignmentMode = .center
        storyLabel.zPosition = 1
        self.addChild(storyLabel)


    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            let secondPageScene = MainMenu(size: self.size)
            secondPageScene.scaleMode = .aspectFill
            view?.presentScene(secondPageScene, transition: SKTransition.fade(withDuration: 0.5))
        }
    }
}
