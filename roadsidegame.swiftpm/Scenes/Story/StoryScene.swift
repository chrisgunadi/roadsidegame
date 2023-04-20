//
//  StoryScene.swift
//
//
//  Created by Christopher Gunadi on 19/04/23.
//

import SpriteKit


class StoryScene: SKScene {
    // MARK: - Content
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .black
        
        let storyText = """
        This little game that I've made is to remember those who were unlucky to have perished while en route to Emergency Care, due to congestion. Sure, this issue doesn't really happen at countries with an advanced emergency care system, but for hometown Jakarta; we sometimes have to drive our sick loved ones in our own car to the hospital due to congestion and logistical issues. I've provided a quick 15 second video snippet that inspired me to make this.
        
        
        
        
        
        Tap to Continue.
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
            let secondPageScene = SecondPageScene(size: self.size)
            secondPageScene.scaleMode = .aspectFill
            view?.presentScene(secondPageScene, transition: SKTransition.fade(withDuration: 0.5))
        }
    }
}
