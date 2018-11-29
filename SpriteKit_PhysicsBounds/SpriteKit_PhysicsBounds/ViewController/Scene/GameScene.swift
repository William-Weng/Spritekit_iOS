//
//  GameScene.swift
//  SpriteKit_PhysicsBounds
//
//  Created by William-Weng on 2018/11/29.
//  Copyright © 2018年 William-Weng. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    let randomIndex = GKShuffledDistribution(lowestValue: 1, highestValue: 5)

    override func didMove(to view: SKView) {
        let safeEgdeRange = CGRect(origin: CGPoint(x: frame.origin.x + 50, y: frame.origin.y + 50), size: frame.size)
        physicsBody = SKPhysicsBody(edgeLoopFrom: safeEgdeRange)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        randomBird(for: touch)
    }
}

extension GameScene {
    
    /// 隨機的Bird方塊
    private func randomBird(for touch: UITouch) {
        
        let position = touch.location(in: self)
        let birdNode = SKSpriteNode(imageNamed: "AngryBird_\(randomIndex.nextInt())")
        let birdBody = SKPhysicsBody(rectangleOf: birdNode.frame.size)
        
        birdNode.physicsBody = birdBody
        birdNode.position = position
        birdNode.zPosition = 1
        
        addChild(birdNode)
    }
}
