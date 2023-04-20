//
//  SecondPageStory.swift
//
//
//  Created by Christopher Gunadi on 19/04/23.
//


import SpriteKit
import AVFoundation

class SecondPageScene: SKScene {
    private var player: AVPlayer?

    override func didMove(to view: SKView) {
        backgroundColor = .black

        let videoURL = Bundle.main.url(forResource: "nosound", withExtension: "mov")
        let asset = AVAsset(url: videoURL!)
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        
        let videoNode = SKVideoNode(avPlayer: player!)
        videoNode.position = CGPoint(x: frame.midX, y: frame.midY)
        
        // Calculate the new size while maintaining the aspect ratio
        let videoSize = asset.tracks(withMediaType: .video).first?.naturalSize ?? CGSize.zero
        let videoAspectRatio = videoSize.width / videoSize.height
        let newHeight = frame.height / 2
        let newWidth = newHeight * videoAspectRatio
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        videoNode.size = newSize
        videoNode.zPosition = 1
        addChild(videoNode)
        
        videoNode.play()
        
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidEnd), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    @objc func videoDidEnd() {
        let thirdPageScene = ThirdPageScene(size: self.size)
        thirdPageScene.scaleMode = .aspectFill
        view?.presentScene(thirdPageScene, transition: SKTransition.fade(withDuration: 0.5))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            let thirdPageScene = ThirdPageScene(size: self.size)
            thirdPageScene.scaleMode = .aspectFill
            view?.presentScene(thirdPageScene, transition: SKTransition.fade(withDuration: 0.5))
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }
}
